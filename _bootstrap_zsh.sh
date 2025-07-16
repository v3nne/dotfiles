#!/bin/bash
set -euo pipefail


install_custom_plugin() {
  url="$1"
  name=$(basename -s .git "$url")
  target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

  if [ ! -d "$target" ]; then
    git clone "$url" "$target"
  else
    echo "$name already exists. Updating…"
    ( cd "$target" && git pull --ff-only )
  fi
}


# Install Oh My Zsh, if it already doesn't exist 
if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Getting oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    --unattended --keep-zshrc --skip-chsh
else
	echo ".oh-my-zsh already found, skipping."
fi


git clone \
  "https://github.com/v3nne/vennes-sorin.zsh-theme.git" \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/vennes-sorin.zsh-theme"

install_custom_plugin "https://github.com/MichaelAquilina/zsh-you-should-use.git"
install_custom_plugin "https://github.com/zsh-users/zsh-autosuggestions.git"
install_custom_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git"

