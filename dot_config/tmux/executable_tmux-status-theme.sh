#!/bin/sh
set -eu

sync_theme() {
    # AppleInterfaceStyle is only set ("Dark") in dark mode; it's absent in light mode
    if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null || :)" = "Dark" ]; then
        mode=dark
        style='fg=#ecece8,bg=#54546D'
    else
        mode=light
        style='fg=#435965,bg=#d4cdd4'
    fi

    current_mode=$(tmux show-option -gqv @tmux-status-theme 2>/dev/null || :)
    if [ "$current_mode" != "$mode" ]; then
        tmux set-option -g window-status-current-style "$style"
        tmux set-option -g @tmux-status-theme "$mode"
        tmux refresh-client -S
    fi
}

if [ "${1:-}" = "--watch" ]; then
    if [ "$(tmux show-option -gqv @tmux-status-theme-watcher 2>/dev/null || :)" = "running" ]; then
        exit 0
    fi

    tmux set-option -g @tmux-status-theme-watcher running
    while tmux show-option -gqv @tmux-status-theme-watcher >/dev/null 2>&1; do
        sync_theme
        sleep 2
    done
else
    sync_theme
fi
