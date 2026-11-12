#!/usr/bin/env bash
# Claude Code statusline: rounded pills for dir, branch, model, ctx, session and weekly.
# Nerd Font glyphs are written as UTF-8 bytes so editors and copy/paste can't strip them.

# kanagawa-paper palette (R;G;B)
GREEN='152;187;108'  # springGreen   #98BB6C
YELLOW='230;195;132' # carpYellow    #E6C384
ORANGE='255;160;102' # surimiOrange  #FFA066
RED='255;93;98'      # peachRed      #FF5D62
NEUTRAL='54;54;70'   # sumiInk5      #363646
LIGHT='220;215;186'  # fujiWhite     #DCD7BA
DARK='22;22;29'      # sumiInk0      #16161D

CAP_L=$'\xEE\x82\xB6'       # U+E0B6 left half circle
CAP_R=$'\xEE\x82\xB4'       # U+E0B4 right half circle
ICON_DIR=$'\xEF\x81\xBB'    # U+F07B folder
ICON_BRANCH=$'\xEE\x9C\xA5' # U+E725 git branch
ICON_MODEL=$'\xF3\xB0\x9A\xA9' # U+F06A9 robot
ICON_CTX=$'\xF3\xB0\x8D\x9B'   # U+F035B memory chip
ICON_SESSION=$'\xEF\x80\x97'   # U+F017 clock
ICON_WEEKLY=$'\xEF\x81\xB3'    # U+F073 calendar
SEP=' '

US=$'\x1f'
IFS="$US" read -r dir model effort ctx session session_left weekly weekly_left < <(jq -r '
  def pct: if type == "number" then round else "--" end;
  def left: if type == "number" and . > now then (. - now | floor) else "" end;
  [
    (.workspace.current_dir // .cwd // ""),
    ((.model.display_name // "") | sub("^Claude "; "") | (split(" ")[0] // "") | ascii_downcase),
    (.effort.level // ""),
    ((.context_window.total_input_tokens // 0) / 1000 | round),
    (.rate_limits.five_hour.used_percentage | pct),
    (.rate_limits.five_hour.resets_at | left),
    (.rate_limits.seven_day.used_percentage | pct),
    (.rate_limits.seven_day.resets_at | left)
  ] | map(tostring) | join("\u001f")
')

# band_color VALUE GREEN_MAX YELLOW_MAX ORANGE_MAX
band_color() {
  if (($1 <= $2)); then
    printf '%s' "$GREEN"
  elif (($1 <= $3)); then
    printf '%s' "$YELLOW"
  elif (($1 <= $4)); then
    printf '%s' "$ORANGE"
  else
    printf '%s' "$RED"
  fi
}

# pill BG FG TEXT (bold when BG is red)
pill() {
  local bold=''
  [[ $1 == "$RED" ]] && bold=$'\033[1m'
  printf '\033[38;2;%sm%s\033[0m%s\033[48;2;%sm\033[38;2;%sm%s\033[0m\033[38;2;%sm%s\033[0m' \
    "$1" "$CAP_L" "$bold" "$1" "$2" "$3" "$1" "$CAP_R"
}

# format_left SECONDS
format_left() {
  local s=$1
  if ((s >= 86400)); then
    printf '%dd%dh' $((s / 86400)) $((s % 86400 / 3600))
  elif ((s >= 3600)); then
    printf '%dh%dm' $((s / 3600)) $((s % 3600 / 60))
  elif ((s >= 60)); then
    printf '%dm' $((s / 60))
  else
    printf '<1m'
  fi
}

# pct_pill ICON VALUE SECONDS_LEFT (countdown only at orange and red)
pct_pill() {
  if [[ $2 == "--" ]]; then
    pill "$NEUTRAL" "$LIGHT" "$1 --"
    return
  fi
  local text="$1 $2%"
  (($2 > 50)) && [[ -n $3 ]] && text+=" $(format_left "$3")"
  pill "$(band_color "$2" 25 50 75)" "$DARK" "$text"
}

line=''
add() {
  line+="${line:+$SEP}$1"
}

if [[ -n $dir ]]; then
  if [[ $dir == "$HOME" ]]; then
    add "$(pill "$NEUTRAL" "$LIGHT" "$ICON_DIR ~")"
  else
    add "$(pill "$NEUTRAL" "$LIGHT" "$ICON_DIR ${dir##*/}")"
  fi
  branch=$(git --no-optional-locks -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null ||
    git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
  [[ -n $branch ]] && add "$(pill "$NEUTRAL" "$LIGHT" "$ICON_BRANCH $branch")"
fi
[[ -n $model ]] && add "$(pill "$NEUTRAL" "$LIGHT" "$ICON_MODEL $model${effort:+ · $effort}")"
add "$(pill "$(band_color "$ctx" 75 100 125)" "$DARK" "$ICON_CTX ${ctx}k")"
add "$(pct_pill "$ICON_SESSION" "$session" "$session_left")"
add "$(pct_pill "$ICON_WEEKLY" "$weekly" "$weekly_left")"

printf '%s\n' "$line"

