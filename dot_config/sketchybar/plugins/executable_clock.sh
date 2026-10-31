#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

day=$(date '+%d' | sed 's/^0//')
case $((day % 10)) in
  1) suffix="st" ;;
  2) suffix="nd" ;;
  3) suffix="rd" ;;
  *) suffix="th" ;;
esac
sketchybar --set "$NAME" label="▏ $(date "+%a %d${suffix} %b %H:%M")"

# sketchybar --set "$NAME" label="▏ $(date '+%a %d %b %H:%M')"

