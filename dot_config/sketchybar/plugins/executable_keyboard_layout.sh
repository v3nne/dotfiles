#!/bin/bash

layout=$(defaults read ~/Library/Preferences/com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID)
case "$layout" in
  *US*) kb="US" ;;
  *Swedish*) kb="SE" ;;
  *) kb="${layout##*.}" ;;
esac

sketchybar --set "$NAME" label="▏ $kb"

