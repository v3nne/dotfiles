#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
9[0-9] | 100)
  ICON=""
  ;;
[6-8][0-9])
  ICON=""
  ;;
[3-5][0-9])
  ICON=""
  ;;
[1-2][0-9])
  ICON=""
  ;;
*) ICON="" ;;
esac

if [[ "$CHARGING" != "" ]]; then
  ICON=""
fi

# CACHE="/tmp/battery-script-cache"
# if [[ ! -f "$CACHE" ]]; then
#   echo "HAS_NOT_NOTIFIED" >"$CACHE"
# fi
#
# if [[ "$CHARGING" != "" && "$PERCENTAGE" -ge 80 && $(cat "$CACHE") == "HAS_NOT_NOTIFIED" ]]; then
#   terminal-notifier -message "Remember to unplug the charger" -title "Battery level is over 80%" -sound Submarine
#   echo "HAS_NOTIFIED" >"$CACHE"
# elif [[ "$PERCENTAGE" -le 79 ]]; then
#   echo "HAS_NOT_NOTIFIED" >"$CACHE"
# fi

sketchybar --set "$NAME" icon="▏ $ICON" label="${PERCENTAGE}%"
