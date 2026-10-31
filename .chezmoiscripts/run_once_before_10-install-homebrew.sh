#!/bin/bash
set -euo pipefail

if [ -x /opt/homebrew/bin/brew ]; then
  exit 0
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
