# shellcheck shell=bash
#
# Shared serialization-lock mechanism for the tmux window lists.
#
# A single tmux/focus action fires several hooks/ticks at once; without
# serialization their runs interleave on a shared cache and on sketchybar's item
# set -- one can hit a teardown branch and --remove every window item while a
# sibling, mid-rebuild, rewrites the cache as if the items still existed, leaving
# the bar blank with a stale cache. macOS has no flock(1), so the mutex is an
# atomic mkdir, broken if a previous holder died with it held.
#
# This is the SINGLE source of truth for that mechanism: the shared renderer
# (window_list_render.sh) serializes its tmux.win.* / tmux.rwin.* mutations
# through it, and the focus controller (focus.sh) wraps its whole remote
# critical section -- poll, offline-state read-modify-write, render/teardown --
# through it too, so overlapping focus/poll/update events can't corrupt the
# remote item set, cache, or persisted state. Both use literally this code, not
# hand-copied copies.
#
# Sourced, never executed: it only defines functions, so it carries no shebang
# and no executable bit. Callers do:  . "$DIR/lock_lib.sh"
#
# Usage:
#   . "$DIR/lock_lib.sh"
#   acquire_lock "$LOCK"       # blocks (breaking a 5s-stale lock) until held; sets
#                              # an EXIT trap that releases it
#   acquire_lock "$LOCK" 15    # same, but breaks only after 15s -- for a holder
#                              # whose critical section can run that long
#
# acquire_lock sets a `trap ... EXIT` to release the lock. A caller that needs
# its own EXIT cleanup must register it BEFORE calling acquire_lock (later traps
# for the same signal replace earlier ones) or fold the release into its own
# trap by calling release_lock.

# acquire_lock <lockdir> [stale_secs]: block until the atomic-mkdir mutex is held,
# breaking a lock older than <stale_secs> (default 5 -- a previous holder that
# died). Installs an EXIT trap so the lock is released however the process leaves.
#
# stale_secs is the only knob that must track how long the holder stays inside the
# critical section: it MUST exceed the holder's worst-case hold, or a coinciding
# waiter reaps the lock mid-hold and the two run concurrently. The renderer's hold
# is sub-second, so it takes the tight 5s default; the focus controller holds
# across an SSH poll (bounded by the devbox-bar keepalives, ~10s worst case) and
# passes a wider window (see $RCTLLOCK in focus.sh).
acquire_lock() {
  local lock="$1"
  local stale_secs="${2:-5}"
  while ! mkdir "$lock" 2>/dev/null; do
    local age=$(( $(date +%s) - $(stat -f %m "$lock" 2>/dev/null || date +%s) ))
    (( age > stale_secs )) && rm -rf "$lock" && continue
    sleep 0.1
  done
  # shellcheck disable=SC2064  # expand $lock now: the trap must outlive this scope
  trap "rm -rf '$lock'" EXIT
}

# release_lock <lockdir>: drop the lock explicitly. acquire_lock's EXIT trap
# already covers normal exit; this is for callers that release early or fold the
# release into their own combined trap.
release_lock() {
  rm -rf "$1"
}
