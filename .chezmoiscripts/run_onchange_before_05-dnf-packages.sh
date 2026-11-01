#!/bin/bash
set -euo pipefail

# Homebrew refuses to install as root, so stop before changing anything
if [ "$(id -u)" -eq 0 ]; then
  echo "Don't run chezmoi as root. Use bootstrap.sh, see the README." >&2
  exit 1
fi

sudo dnf install -y @development-tools zsh git curl file procps-ng clang unzip

sudo usermod -s "$(command -v zsh)" "$(id -un)"
