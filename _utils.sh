#!/bin/bash
CURRENT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE_PATH="$CURRENT_PATH/_install.log"


function write_to_log() {
  local CONTENT=$1

  [ -f "$LOG_FILE_PATH" ] || touch "$LOG_FILE_PATH"

  printf "%s\n\n" "[$(date +'%Y-%m-%d %H:%M:%S')] $CONTENT" \
    >> "$LOG_FILE_PATH"
}


function print_section() {
  local TEXT=$1

  printf "\n\n   === %s ===\n\n" "$TEXT"
}


function try_install_package() {
  local -a INSTALL_CMD=( "$@" )    # collect *all* positional args into an array
  local PACKAGE=${INSTALL_CMD[-1]} # the last element
  unset 'INSTALL_CMD[-1]'          # remove it from the array, so INSTALL_CMD now holds just the command+flags

  # run the command, run if statement if it returns non 0 exit code
  if ! OUTPUT=$("${INSTALL_CMD[@]}" "$PACKAGE" 2>&1); then
    cat <<-EOF

    FAILED TO INSTALL PACKAGE: ${PACKAGE}
    You can check the logs in "${LOG_FILE_PATH}"
EOF

    write_to_log "[ERROR] '${INSTALL_CMD[*]} $PACKAGE' failed: $OUTPUT"
  fi
}


function missing_software_guard() {
  local SOFTWARE=$1

  if ! command -v "$SOFTWARE" >/dev/null 2>&1; then
    printf "\n%s is not installed or not in your path\naborting...\n\n" \
      "$SOFTWARE"
    exit 1
  fi
}


# ( ) instead of { } starts a subshell, so the globs live & die in this function
function stow_dotfiles() (
  shopt -s nullglob dotglob

  # Loop through items in current directory
  for ENTRY in *; do
    case "$ENTRY" in
      _*|.git|.gitignore|README.md|.stow-local-ignore)
        # matched one of the ignore‑patterns → do nothing
        ;;
      *)
        if stow -n -v "$ENTRY"; then
          stow "$ENTRY" >>"$LOG_FILE_PATH" 2>&1
          write_to_log "[INFO] stowed '$ENTRY'"
        else
          write_to_log "[WARNING] stow conflict detected for '$ENTRY' - skipping..."
        fi
        ;;
    esac
  done
)

