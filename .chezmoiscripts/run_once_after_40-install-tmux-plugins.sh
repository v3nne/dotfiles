#!/bin/bash
set -euo pipefail

eval "$(/opt/homebrew/bin/brew shellenv)"

# TPM needs a tmux server, and killing one would end any running sessions
if tmux list-sessions >/dev/null 2>&1; then
  echo "tmux is running: skipping plugin install, press prefix + I instead" >&2
  exit 0
fi

tmux new-session -d -s tpm-install
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
tmux kill-server
