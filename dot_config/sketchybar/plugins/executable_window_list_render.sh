#!/usr/bin/env bash
#
# Window-list differ / renderer (shared, parameterized).
#
# Extracted from the local tmux plugin so the local renderer (namespace
# `tmux.win.*`) and the remote renderer (namespace `tmux.rwin.*`) share ONE
# diff/render implementation and stay byte-for-byte consistent in behavior.
#
# Given the previous-cache text and the current `list-windows`-format text, this
# diffs them, emits ADD/UPDATE/REMOVE ops, turns those into a single batched
# SketchyBar invocation, and writes the new cache. It preserves the existing
# safety nets from the original plugin:
#   - a serialization lock (the shared atomic-mkdir mutex from lock_lib.sh),
#   - cache-vs-live reconciliation (a missing active-window item drops the stale
#     cache and forces a full rebuild),
#   - the empty-cache full-rebuild path.
#
# This unit owns NO context/visibility policy and does NO tmux I/O: the caller
# decides whether a tmux server exists and what `draw` state new items get. It is
# purely "diff these two window lists into this namespace with these colors".
#
# Usage (render):
#   window_list_render.sh \
#     --namespace tmux.win \
#     --cache "$HOME/.cache/sketchybar_tmux.cache" \
#     --lock  "$HOME/.cache/sketchybar_tmux.lock" \
#     --active-bg 0xff54546D --active-fg 0xffCEC9AF --default-fg 0xffB4B09B \
#     --draw on \
#     --windows "$windows"
#
# Usage (teardown -- remove every item in the namespace and drop the cache):
#   window_list_render.sh \
#     --namespace tmux.win \
#     --cache "$HOME/.cache/sketchybar_tmux.cache" \
#     --lock  "$HOME/.cache/sketchybar_tmux.lock" \
#     --teardown
#
# `--windows` is the current `tmux list-windows -F '#{window_active}\t#{window_index}\t#{window_name}'`
# output. The active/index/name fields are tab-separated.
#
# Both modes run under the serialization lock, so a teardown can never interleave
# with a sibling rebuild (the race the lock was introduced to prevent).

NAMESPACE=""
CACHE=""
LOCK=""
ACTIVE_BG=""
ACTIVE_FG=""
DEFAULT_FG=""
draw="off"
windows=""
teardown=0

while (( $# > 0 )); do
  case "$1" in
    --namespace)  NAMESPACE="$2"; shift 2 ;;
    --cache)      CACHE="$2";     shift 2 ;;
    --lock)       LOCK="$2";      shift 2 ;;
    --active-bg)  ACTIVE_BG="$2"; shift 2 ;;
    --active-fg)  ACTIVE_FG="$2"; shift 2 ;;
    --default-fg) DEFAULT_FG="$2"; shift 2 ;;
    --draw)       draw="$2";      shift 2 ;;
    --windows)    windows="$2";   shift 2 ;;
    --teardown)   teardown=1;     shift   ;;
    *) echo "window_list_render.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
done

# Guard the interface: --namespace/--cache/--lock are required by contract but
# the parse loop above can't enforce presence. An empty namespace is catastrophic,
# not a no-op -- the teardown selector degrades from /tmux\.win\..*/ to /\..*/,
# which matches EVERY sketchybar item with a dot (battery, clock, front_app, ...)
# and wipes the bar. Fail loud at the module boundary instead.
if [[ -z "$NAMESPACE" || -z "$CACHE" || -z "$LOCK" ]]; then
  echo "window_list_render.sh: --namespace/--cache/--lock required" >&2
  exit 2
fi

mkdir -p "$(dirname "$CACHE")"

# Serialize concurrent runs. A single tmux action fires several hooks at once
# (after-select-window + pane-focus-in + session-window-changed, ...), each
# triggering an update. Without this lock those runs interleave on the cache
# and on sketchybar's item set: one can hit the teardown branch and --remove
# every window item while a sibling, mid-rebuild, rewrites the cache as if the
# items still existed, leaving the bar blank with a stale cache that the
# early-exit below then refuses to rebuild. The mechanism (atomic-mkdir mutex,
# stale-break) lives in lock_lib.sh -- the single source of truth the focus
# controller serializes its remote critical section through too.
# shellcheck source=plugins/lock_lib.sh
. "$(dirname "$0")/lock_lib.sh"
acquire_lock "$LOCK"

# Teardown: remove every item in the namespace and drop the cache. Held under
# the same lock as a render so it cannot interleave with a sibling rebuild. The
# regex escapes the namespace's dots (sketchybar item names use `.` literally,
# but the selector is a regex) -- e.g. namespace `tmux.win` -> /tmux\.win\..*/.
if (( teardown )); then
  ns_re="${NAMESPACE//./\\.}"
  sketchybar --remove "/${ns_re}\..*/" >/dev/null 2>&1
  rm -f "$CACHE"
  exit 0
fi

# Skip entirely if nothing changed since last render -- but only if the items
# the cache claims to have rendered actually still exist in sketchybar. This is
# the safety net: should the live item set ever diverge from the cache, we
# detect the missing active-window item, drop the stale cache, and fall through
# to a full rebuild instead of wedging the bar.
if [[ -f "$CACHE" ]] && [[ "$(cat "$CACHE")" == "$windows" ]]; then
  active_idx=$(awk -F'\t' '$1 == 1 { print $2; exit }' <<< "$windows")
  if sketchybar --query "$NAMESPACE.$active_idx" &>/dev/null; then
    exit 0
  fi
  rm -f "$CACHE"
fi

# Diff prev (cache) against curr (windows) — emit ADD/UPDATE/REMOVE per line.
# Format: <op>\t<active>\t<index>\t<name>  (active/name empty for REMOVE)
# No-cache path: everything is new. (Can't use awk's FNR==NR idiom with an
# empty first file — NR stays at 0, so FNR==NR matches every line of the
# second file and nothing gets emitted.)
if [[ -f "$CACHE" ]]; then
  diff_ops=$(awk -F'\t' '
    FNR == NR { prev_a[$2] = $1; prev_n[$2] = $3; next }
    {
      seen[$2] = 1
      if (!($2 in prev_a))
        print "ADD\t"    $1 "\t" $2 "\t" $3
      else if ($1 != prev_a[$2] || $3 != prev_n[$2])
        print "UPDATE\t" $1 "\t" $2 "\t" $3
    }
    END {
      # Use "-" placeholder for unused fields — bash collapses consecutive
      # IFS-whitespace tabs into a single delimiter, which would shift the
      # index into the wrong read variable.
      for (i in prev_a) if (!(i in seen)) print "REMOVE\t-\t" i "\t-"
    }
  ' "$CACHE" <(echo "$windows"))
else
  diff_ops=$(awk -F'\t' '{ print "ADD\t" $1 "\t" $2 "\t" $3 }' <<< "$windows")
fi

# Build a single batched sketchybar invocation
args=()

while IFS=$'\t' read -r op a i n; do
  [[ -z "$op" ]] && continue
  item="$NAMESPACE.$i"
  case "$op" in
    REMOVE)
      args+=(--remove "$item")
      ;;
    ADD)
      args+=(--add item "$item" left)
      if [[ "$a" == "1" ]]; then
        args+=(--set "$item"
               icon.drawing=off
               drawing=$draw
               label="${i}:${n}"
               label.color=$ACTIVE_FG
               background.color=$ACTIVE_BG
               background.height=18
               background.drawing=on)
      else
        args+=(--set "$item"
               icon.drawing=off
               drawing=$draw
               label="${i}:${n}"
               label.color=$DEFAULT_FG
               background.height=18
               background.drawing=off)
      fi
      ;;
    UPDATE)
      if [[ "$a" == "1" ]]; then
        args+=(--set "$item"
               label="${i}:${n}"
               label.color=$ACTIVE_FG
               background.color=$ACTIVE_BG
               background.drawing=on)
      else
        args+=(--set "$item"
               label="${i}:${n}"
               label.color=$DEFAULT_FG
               background.drawing=off)
      fi
      ;;
  esac
done <<< "$diff_ops"

if (( ${#args[@]} > 0 )); then
  sketchybar "${args[@]}"
fi

printf '%s' "$windows" > "$CACHE"
