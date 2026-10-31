#!/usr/bin/env bash
#
# Focus controller (thin glue) -- the single authority over which tmux context
# the bar draws.
#
# Invoked on:
#   - ghostty_focus       (AeroSpace on-focus-changed, for snappy switches)
#   - front_app_switched  (app-level focus changes)
#   - a ~1s update_freq tick (safety net: tmux is entered manually, so the
#     title can gain its marker with no focus change at all; and, for the devbox
#     context, this same tick is the ~1s remote poll cadence)
#
# It reads the focused window's (app, title), runs the pure Context Resolver,
# and draws exactly one context -- local, devbox, or nothing -- hiding the
# others. front_app.sh and tmux.sh no longer decide visibility independently;
# they defer to the context resolved here.
#
# Local items keep updating event-driven from the local tmux hooks; the
# controller only governs their *visibility*. The devbox (remote) context has no
# such hooks -- the Mac can't see the remote tmux's events -- so the controller
# actively POLLS it (over the warm `devbox-bar` SSH master) ONLY while the devbox
# window is focused, and renders the result into the parallel tmux.rwin.*
# namespace via the shared renderer.
#
# Offline/grace handling (slice 06): each poll result is fed through the pure
# Offline State Machine (offline_state.sh). A brief blip keeps the last-known
# window list for a short grace period (no flapping); after ~2-3 consecutive
# failures the bar swaps to an explicit `devbox ⚠ unreachable` indicator; a
# successful poll returns to the live list. This controller owns the I/O the
# state machine refuses: it persists prev_state/fail_count across the ~1s polls
# in a small state file (RSTATE) and renders the directive the machine returns.

DIR="$(dirname "$0")"
RENDER="$DIR/window_list_render.sh"
POLL="$DIR/remote_poll.sh"
OFFLINE="$DIR/offline_state.sh"

# Remote (devbox) render namespace + its own cache/lock, parallel to the local
# tmux.win bookkeeping so the two contexts never share state. The R* paths below
# share one cache-root prefix; sketchybarrc's reload-reset list must stay in sync
# with the set of files declared here.
CACHE="$HOME/.cache/sketchybar_"
RNS="tmux.rwin"
RCACHE="${CACHE}rtmux.cache"
RLOCK="${CACHE}rtmux.lock"

# Controller-level serialization lock, distinct from the renderer's $RLOCK.
# focus.sh is driven by three sources (ghostty_focus, front_app_switched, the
# ~1s tick), so two invocations can overlap. The remote critical section below
# is a read-modify-write across the offline state (RSTATE), the connected marker
# (RCONNECTED), the remote cache, and the tmux.rwin.* item set -- a poll feeding
# a decision feeding a render. Run unsynchronized, overlapping invocations
# interleave there: lost fail_count increments, a `: > RCONNECTED` racing a
# teardown's `rm -f`, or a cache reflecting a different poll than the items.
# We wrap that whole section in the SHARED lock mechanism (lock_lib.sh) the
# renderer uses, so remote rendering is serialized exactly like local rendering.
#
# It MUST be a different lock from $RLOCK: the renderer re-acquires $RLOCK inside
# this section, and an atomic-mkdir mutex is not reentrant -- holding $RLOCK here
# would deadlock the inner render/teardown.
RCTLLOCK="${CACHE}rtmux.ctl.lock"

# Stale-break window for $RCTLLOCK. Unlike the renderer's sub-second hold (which
# takes lock_lib's tight 5s default), this lock wraps an SSH poll over the warm
# `devbox-bar` master. That poll's worst case is bounded by the alias's keepalives
# (ConnectTimeout 2, ServerAliveInterval 5 x ServerAliveCountMax 2 -> ~10s on a
# hung master; see ~/.ssh/config). The stale-break MUST sit comfortably above that
# worst case, or a coinciding ~1s tick would see the lock as stale, reap it, and
# run the remote read-modify-write concurrently with the still-polling holder --
# the exact race this lock exists to prevent. 15s clears the ~10s ceiling with
# margin while still self-healing a genuinely dead holder within a few ticks.
RCTLLOCK_STALE=15

# Persisted offline-state-machine state ($prev_state for the next poll). The
# pure state machine is I/O-free, so the controller round-trips its single line
# of state here across the ~1s polls. A missing file = clean start (no prior
# failures), which is exactly the state machine's empty-prev contract.
RSTATE="${CACHE}rtmux.state"

# Controller-owned "have we ever drawn a real remote list this focus session?"
# marker. The pure state machine deliberately does NOT carry this bit (it would
# pollute the transition with controller bookkeeping); instead the controller
# touches this file the first time it renders `connected` and removes it on
# teardown. It exists to disambiguate cold-start `stale`: a `stale` hold has a
# last-known list to hold ONLY if we have connected at least once -- otherwise
# there is nothing on screen and holding would render an empty bar
# indistinguishable from "not in tmux". Present => a real list was drawn.
RCONNECTED="${CACHE}rtmux.connected"

# Same palette as the local list (tmux.sh): the remote list must be
# styled identically -- the only perceived difference is the devbox badge. Both
# lists source one palette so "identical" is structural, not hand-copied.
# shellcheck source=plugins/palette.sh
. "$DIR/palette.sh"

# Shared serialization-lock mechanism (atomic-mkdir mutex) -- the SAME one the
# renderer uses. We serialize the whole remote critical section through it.
# shellcheck source=plugins/lock_lib.sh
. "$DIR/lock_lib.sh"

# hide_remote_list: the shared core of dropping the remote window list --
# renderer `--teardown` (every tmux.rwin.* item + cache) plus hiding the remote
# session item and the devbox badge. This is the trio common to BOTH teardown
# paths (full teardown and the `unreachable` swap); each caller appends the bits
# that diverge (the persisted state file and the unreachable indicator's
# polarity), so a future remote-namespace item is hidden in exactly one place.
hide_remote_list() {
  "$RENDER" --namespace "$RNS" --cache "$RCACHE" --lock "$RLOCK" --teardown
  sketchybar --set tmux_rsession drawing=off \
             --set devbox_badge drawing=off >/dev/null 2>&1
}

# remote_teardown: drop every tmux.rwin.* item + cache, and hide the remote
# session item, devbox badge, and the unreachable indicator. Also drop the
# persisted offline state so re-entering the devbox context starts the grace
# machine fresh (no stale fail_count carried across a context switch). Used
# whenever the active context is not devbox, so leaving the remote context never
# leaves a stale remote list -- or a stale `unreachable` -- behind.
remote_teardown() {
  hide_remote_list
  rm -f "$RSTATE" "$RCONNECTED"
  sketchybar --set devbox_unreachable drawing=off >/dev/null 2>&1
}

# Resolve the context of the currently focused window. The resolver's --current
# mode owns the aerospace read + resolution, so this controller and tmux.sh
# share one acquisition path. (Done BEFORE taking the lock -- it is a pure read
# that touches no remote state.)
context=$("$DIR/context_resolver.sh" --current)

# Serialize the entire remote critical section. Every branch below mutates the
# remote item set / cache / persisted state (a render or a teardown), and
# overlapping focus.sh invocations must not interleave there. Held until the
# script exits (lock_lib installs an EXIT trap), so the poll -> decide -> render
# read-modify-write is atomic w.r.t. a sibling invocation. The inner renderer
# still takes its own $RLOCK; that is a DIFFERENT lock (see $RCTLLOCK above), so
# there is no self-deadlock. The wider $RCTLLOCK_STALE window (vs the renderer's
# 5s default) is what keeps a coinciding tick from reaping this lock mid-poll.
acquire_lock "$RCTLLOCK" "$RCTLLOCK_STALE"

case "$context" in
  local)
    # Local tmux is focused: show the local window list + session item. Their
    # *content* is still updated event-driven by tmux.sh / tmux_session.sh; we
    # only govern visibility here. Tear down the remote context entirely -- and
    # do NOT poll the devbox, so no SSH traffic is incurred when local.
    sketchybar --set '/tmux\.win\..*/' drawing=on \
               --set tmux_session drawing=on >/dev/null 2>&1
    remote_teardown
    ;;

  devbox:*)
    # The devbox window is focused: hide the local context, then poll the remote
    # tmux over the warm `devbox-bar` master at this ~1s tick and mirror it into
    # tmux.rwin.* via the shared renderer. The context's host label (devbox:<host>)
    # is informational only; the poll target is the fixed `devbox-bar` ssh alias,
    # so the poller takes no host argument (see remote_poll.sh's interface note).
    sketchybar --set '/tmux\.win\..*/' drawing=off \
               --set tmux_session drawing=off >/dev/null 2>&1

    result=$("$POLL")

    # Decode the structured poll result in ONE pass, so the SESSION/WINDOW wire
    # protocol is read in a single place (the poller is the only other site that
    # knows it). SESSION carries the session name/index; each WINDOW carries the
    # renderer's <active>\t<index>\t<name>. The ok/notok status line is decoded
    # by the Offline State Machine below, not here -- we extract only the payload
    # the `connected` render path needs.
    #
    #   ok
    #   SESSION<TAB><name><TAB><index>
    #   WINDOW<TAB><active><TAB><index><TAB><name>  (zero or more)
    sname=""
    sidx=""
    windows=""
    # `read` with four vars over a 4+-field line collects everything past the
    # third tab into f3, so a tab inside a window name survives intact (the
    # poller keeps the name as the whole trailing field too -- tab-safe end to
    # end). f1/f2 (active/index) are tab-free.
    while IFS=$'\t' read -r tag f1 f2 f3; do
      case "$tag" in
        SESSION)  sname="$f1"; sidx="$f2" ;;
        WINDOW)   windows+="${windows:+$'\n'}${f1}"$'\t'"${f2}"$'\t'"${f3}" ;;
      esac
    done <<< "$result"

    # Feed this poll through the pure Offline State Machine, carrying the
    # state persisted from the previous poll (absent on the first tick of a
    # focus session -> a clean start). The machine returns two tab-tagged lines:
    #   STATE<TAB><next state>   -- persist verbatim for the next poll
    #   RENDER<TAB><directive>   -- connected | stale | unreachable
    # The full poll result is the machine's stdin; it branches only on the
    # leading ok/notok, leaving the SESSION/WINDOW protocol to us.
    prev_state=""
    [[ -f "$RSTATE" ]] && prev_state=$(cat "$RSTATE")

    sm=$(printf '%s' "$result" | "$OFFLINE" --prev "$prev_state")
    next_state=""
    render=""
    while IFS=$'\t' read -r tag rest; do
      case "$tag" in
        STATE)  next_state="$rest" ;;
        RENDER) render="$rest" ;;
      esac
    done <<< "$sm"

    # Persist the new state for the next poll (the I/O the pure machine refuses).
    # next_state is opaque to the controller -- it round-trips verbatim. Its wire
    # grammar (connected | stale<TAB><n> | unreachable) is owned and documented
    # by offline_state.sh; we never parse its internals here.
    printf '%s\n' "$next_state" > "$RSTATE"

    case "$render" in
      connected)
        # Live poll succeeded: hide the unreachable indicator and render the
        # remote window list, styled identically to the local one, with new
        # items drawn on (the devbox context is, by definition, the focused one).
        sketchybar --set devbox_unreachable drawing=off >/dev/null 2>&1
        "$RENDER" \
          --namespace "$RNS" \
          --cache "$RCACHE" \
          --lock "$RLOCK" \
          --active-bg "$ACTIVE_BG" \
          --active-fg "$ACTIVE_FG" \
          --default-fg "$DEFAULT_FG" \
          --draw on \
          --windows "$windows"

        # Right-side remote session item (mirrors the local tmux_session format)
        # and the persistent devbox badge, shown while the remote context is live.
        sketchybar --set tmux_rsession label="$sname [$sidx] ▏" drawing=on \
                   --set devbox_badge drawing=on >/dev/null 2>&1

        # Record that a real list has been drawn this focus session, so a later
        # `stale` hold knows it has a genuine last-known list to hold (see NB1
        # cold-start handling in the `stale` branch below).
        : > "$RCONNECTED"
        ;;

      stale)
        # A brief blip inside the grace window. The `stale` directive means
        # "hold the last-known list" -- but that only makes sense if a real list
        # was ever drawn this session. On a COLD start (the first poll(s) of a
        # freshly entered devbox context fail before any success), there is
        # nothing on screen to hold: holding here would leave an empty bar
        # indistinguishable from "not in tmux". So:
        #   - if we have connected at least once -> genuine hold, no re-render,
        #     no teardown (the no-flap behavior the grace window exists for);
        #   - if we have NEVER connected -> there is no last-known list; surface
        #     the explicit `devbox ⚠ unreachable` indicator instead of an empty
        #     bar, so a cold/connecting devbox is visibly distinct from the
        #     not-in-tmux bar. A later success clears it and draws the live list.
        if [[ -f "$RCONNECTED" ]]; then
          : # genuine hold of the existing list -- nothing to do this tick.
        else
          hide_remote_list
          sketchybar --set devbox_unreachable drawing=on >/dev/null 2>&1
        fi
        ;;

      unreachable)
        # Grace exhausted: tear down the (now-stale) remote window list and the
        # devbox badge/session, and show the explicit `devbox ⚠ unreachable`
        # indicator instead -- visually distinct from the empty / not-in-tmux
        # bar, which shows no remote items at all. Shares hide_remote_list with
        # remote_teardown; only the indicator polarity diverges (on here).
        hide_remote_list
        sketchybar --set devbox_unreachable drawing=on >/dev/null 2>&1
        ;;
    esac
    ;;

  *)
    # none: not a terminal, or a terminal not in tmux. Hide both namespaces, the
    # badge, and the unreachable indicator (remote_teardown clears all three plus
    # the offline state); poll nothing.
    sketchybar --set '/tmux\.win\..*/' drawing=off \
               --set tmux_session drawing=off >/dev/null 2>&1
    remote_teardown
    ;;
esac
