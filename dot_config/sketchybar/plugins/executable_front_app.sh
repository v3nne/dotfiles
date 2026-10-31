#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# This item only renders the focused app name. It NO LONGER decides the
# visibility of the tmux items -- that is owned solely by the focus controller
# (plugins/focus.sh), which resolves the focused window's tmux context and
# shows/hides tmux.win.* and tmux_session accordingly. The controller is also
# subscribed to front_app_switched, so it re-evaluates on the same event.

app="$INFO"

if [ "$SENDER" = "front_app_switched" ]; then
  case "$app" in
    Ghostty|kitty) sketchybar --set "$NAME" label="" ;;
    *)             sketchybar --set "$NAME" label="$app" ;;
  esac
fi
