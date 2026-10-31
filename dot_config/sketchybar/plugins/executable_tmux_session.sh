#!/usr/bin/env bash

# This item renders the current local tmux session label. It does NOT decide its
# own visibility on focus -- the focus controller (plugins/focus.sh) owns that,
# showing tmux_session only when the local tmux context is focused. Here we only
# keep the label content current; the one exception is the teardown below, which
# hides the item when there is no tmux server at all (nothing to show).

# If no tmux server is running, hide the item (no session content to render)
if ! tmux info &>/dev/null; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

# Get current session name
current_session=$(tmux display-message -p '#S')

# Get the index (line number) of the current session
session_index=$(tmux list-sessions -F '#{session_name}' | \
  awk -v session="$current_session" '$0 == session {print NR; exit}')

# Format: session_name [session_index]
label="$current_session [$session_index]"

# Update content only; visibility is governed by the focus controller.
sketchybar --set "$NAME" label="$label ▏"
