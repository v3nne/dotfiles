#!/bin/bash
set -euo pipefail

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  exit 0
fi

# PROFILE=/dev/null stops the installer editing .zshrc, which already loads nvm
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | PROFILE=/dev/null bash
