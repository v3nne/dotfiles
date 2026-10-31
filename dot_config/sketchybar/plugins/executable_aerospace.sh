##!/usr/bin/env bash

#workspace=$(aerospace list-workspaces --focused)
#sketchybar --set "$NAME" label="$workspace"
#


# Use the value Aerospace passed on the event, else query directly
ws=$(printf "%02d" "${FOCUSED_WORKSPACE:-$(/opt/homebrew/bin/aerospace list-workspaces --focused)}")
sketchybar --set "$NAME" label="$ws"
