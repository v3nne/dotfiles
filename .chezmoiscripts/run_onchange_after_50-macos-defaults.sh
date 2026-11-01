#!/bin/bash
set -euo pipefail

# Dock
defaults write com.apple.dock tilesize -int 28
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock show-recents -bool false

# Desktop & Stage Manager
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true

# Menu bar: value copied from this Mac, set to always hide
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 2

# Trackpad: tap to click, three-finger swipe between pages
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool false

# Keyboard: disable the input source shortcuts
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:60:enabled false" "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:61:enabled false" "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null || true

# Finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder FinderSpawnTab -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowRecentTags -bool false

# Default apps: open audio files with QuickTime Player
if command -v duti >/dev/null 2>&1; then
  for ext in mp3 m4a m4b aac wav aiff aif flac; do
    duti -s com.apple.QuickTimePlayerX ".$ext" all
  done
fi

killall Dock Finder ControlCenter 2>/dev/null || true
