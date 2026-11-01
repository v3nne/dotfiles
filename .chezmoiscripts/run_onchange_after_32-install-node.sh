#!/bin/bash
# No set -eu here: nvm doesn't work under either

export NVM_DIR="$HOME/.nvm"
\. "$NVM_DIR/nvm.sh"

# A plain `nvm install 26` could pull a newer 26.x
if [ "$(nvm version 26)" = "N/A" ]; then
  nvm install 26 || exit 1
fi

nvm alias default 26
