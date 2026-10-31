# shellcheck shell=bash
#
# Shared sketchybar window-list palette (Kanagawa-ish). Sourced by every plugin
# that renders a tmux window list -- the local list (tmux.sh) and the remote
# devbox list (focus.sh) -- so "the remote list is styled identically to the
# local one" is enforced by one source of truth, not by hand-copied literals.
#
# Sourced, never executed: it only assigns the palette vars, so it carries no
# shebang and no executable bit. Callers do:  . "$DIR/palette.sh"

# Window-list item colors (active item background/foreground, inactive
# foreground). Shared by the local and remote window lists.
ACTIVE_BG=0xff54546D
ACTIVE_FG=0xffCEC9AF
DEFAULT_FG=0xffB4B09B

# Devbox badge: its label reuses the active-item foreground; BADGE_BG is the
# badge's own accent. Centralized here so a recolor is one edit, not a
# grep-and-replace across sketchybarrc.
BADGE_FG=$ACTIVE_FG
BADGE_BG=0xff957FB8

# `devbox ⚠ unreachable` indicator (slice 06): shown after the offline grace
# period expires. A warm red (Kanagawa waveRed) so "disconnected" reads as an
# alert and is visually distinct from the empty / not-in-tmux bar -- which shows
# no remote items at all -- rather than looking like just another window entry.
UNREACHABLE_FG=0xffE82424
