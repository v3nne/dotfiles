#!/usr/bin/env bash
#
# Context Resolver (pure function, no I/O).
#
# Given the focused window's (app_name, window_title), decide which tmux
# context the bar should draw. This is the single authority for "what am I
# looking at"; the focus controller calls it and renders accordingly.
#
# Usage:
#   context_resolver.sh "<app_name>" "<window_title>"
# or pipe a single "<app_name>|<window_title>" line on stdin:
#   printf '%s\n' "$app|$title" | context_resolver.sh
# or resolve the *currently focused* window in one shot:
#   context_resolver.sh --current
#
# Output (stdout), exactly one of:
#   local              focused window is the local tmux server
#   devbox:<host>      focused window is a remote (devbox) tmux server
#   none               not a terminal, or not in tmux
#
# Rules:
#   - app must be a terminal (Ghostty/kitty) else `none`
#   - title must match the marker grammar ^tmuxctx:([LR]):(\S+) else `none`
#   - L -> local ; R -> devbox:<host-label>
#
# The marker is stamped into the terminal title by tmux's set-titles-string
# (see tmux.conf.tmpl): local emits "tmuxctx:L:local ...", a devbox emits
# "tmuxctx:R:<host> ...". A terminal not running tmux carries no marker.

AEROSPACE="/opt/homebrew/bin/aerospace"

# --current: acquire the focused window's (app, title) ourselves, then resolve.
# This is the single home for "what context is focused right now" -- focus.sh
# (the controller) and tmux.sh (initial draw state for new items) both call it,
# so the aerospace read, its format string, and the resolver pipe live in one
# place rather than being copy-pasted at each call site.
if [[ "$1" == "--current" ]]; then
  "$AEROSPACE" list-windows --focused \
    --format '%{app-name}|%{window-title}' 2>/dev/null \
    | "$0"
  exit $?
fi

app="$1"
title="$2"

# Allow a single piped "app|title" line as an alternative to positional args.
if [[ -z "$app" && -z "$title" ]]; then
  IFS='|' read -r app title
fi

case "$app" in
  Ghostty|kitty) ;;
  *) echo none; exit 0 ;;
esac

# Marker grammar: tmuxctx:<L|R>:<host-label> at the start of the title.
if [[ "$title" =~ ^tmuxctx:([LR]):([^[:space:]]+) ]]; then
  side="${BASH_REMATCH[1]}"
  host="${BASH_REMATCH[2]}"
  # The regex above already constrains $side to exactly L or R, so no default arm.
  case "$side" in
    L) echo local ;;
    R) echo "devbox:$host" ;;
  esac
  exit 0
fi

echo none
