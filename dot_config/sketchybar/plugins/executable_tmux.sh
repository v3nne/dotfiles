#!/usr/bin/env bash
#
# Local tmux window-list plugin -- a thin caller over the shared window-list
# renderer (plugins/window_list_render.sh). This script owns only the LOCAL
# specifics: detecting the local tmux server, gathering its window list, choosing
# the initial draw state for new items, and passing the local namespace + colors.
# The diff/render logic, the serialization lock, the cache-vs-live reconciliation,
# and the full-rebuild fallback all live in the shared renderer so the local and
# remote contexts stay byte-for-byte consistent.

DIR="$(dirname "$0")"
RENDER="$DIR/window_list_render.sh"

NAMESPACE="tmux.win"
CACHE="$HOME/.cache/sketchybar_tmux.cache"
LOCK="$HOME/.cache/sketchybar_tmux.lock"

# Window-list palette, shared with the remote list (focus.sh) so both stay
# byte-for-byte identical. See plugins/palette.sh.
# shellcheck source=plugins/palette.sh
. "$DIR/palette.sh"

# If no tmux server is running, tear everything down. The teardown runs under the
# renderer's serialization lock (so it can't interleave with a sibling rebuild),
# then we hide this event item itself.
if ! tmux info &>/dev/null; then
  "$RENDER" --namespace "$NAMESPACE" --cache "$CACHE" --lock "$LOCK" --teardown
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

sketchybar --set "$NAME" drawing=off label=""

# Current tmux window state
windows=$(tmux list-windows -F $'#{window_active}\t#{window_index}\t#{window_name}')

# Visibility for newly-created items only. This script does NOT decide visibility
# policy independently -- the focus controller (plugins/focus.sh) is the single
# authority. To give a brand-new item the correct initial drawing state (instead
# of flashing on/off until the controller's next tick), consult that same
# authority via the resolver's --current mode (shared with focus.sh, so the
# focused-context acquisition has one home). The controller then keeps existing
# items' visibility in sync from then on.
context=$("$DIR/context_resolver.sh" --current)
case "$context" in
  local) draw="on" ;;
  *)     draw="off" ;;
esac

# Hand off to the shared renderer with the local namespace + colors. It holds the
# lock, reconciles cache vs. live, diffs prev against curr, batches the resulting
# ADD/UPDATE/REMOVE ops into a single sketchybar call, and rewrites the cache.
"$RENDER" \
  --namespace "$NAMESPACE" \
  --cache "$CACHE" \
  --lock "$LOCK" \
  --active-bg "$ACTIVE_BG" \
  --active-fg "$ACTIVE_FG" \
  --default-fg "$DEFAULT_FG" \
  --draw "$draw" \
  --windows "$windows"
