#!/bin/bash
set -euo pipefail

CURRENT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_NAME="$( basename "$CURRENT_PATH" )"
PARENT_DIR="$( dirname "$CURRENT_PATH" )"

source "$CURRENT_PATH/_utils.sh"


if [ "$PARENT_DIR" != "$HOME" ]; then
  printf "❌ Parent directory is NOT home\naborting..."
  exit 1
fi




cat <<'EOF'

    ██   ██ ███████ ██      ██       ██████       █████  ███    ██ ██████      ██     ██ ███████ ██       ██████  ██████  ███    ███ ███████ 
    ██   ██ ██      ██      ██      ██    ██     ██   ██ ████   ██ ██   ██     ██     ██ ██      ██      ██      ██    ██ ████  ████ ██      
    ███████ █████   ██      ██      ██    ██     ███████ ██ ██  ██ ██   ██     ██  █  ██ █████   ██      ██      ██    ██ ██ ████ ██ █████   
    ██   ██ ██      ██      ██      ██    ██     ██   ██ ██  ██ ██ ██   ██     ██ ███ ██ ██      ██      ██      ██    ██ ██  ██  ██ ██      
    ██   ██ ███████ ███████ ███████  ██████      ██   ██ ██   ████ ██████       ███ ███  ███████ ███████  ██████  ██████  ██      ██ ███████ 



                             `8.`888b           ,8' 8 88888888888  b.             8 b.             8 8 88888888888  
                              `8.`888b         ,8'  8 8888         888o.          8 888o.          8 8 8888         
                               `8.`888b       ,8'   8 8888         Y88888o.       8 Y88888o.       8 8 8888         
                                `8.`888b     ,8'    8 8888         .`Y888888o.    8 .`Y888888o.    8 8 8888         
                                 `8.`888b   ,8'     8 88888888888  8o. `Y888888o. 8 8o. `Y888888o. 8 8 88888888888  
                                  `8.`888b ,8'      8 8888         8`Y8o. `Y88888o8 8`Y8o. `Y88888o8 8 8888         
                                   `8.`888b8'       8 8888         8   `Y8o. `Y8888 8   `Y8o. `Y8888 8 8888         
                                    `8.`888'        8 8888         8      `Y8o. `Y8 8      `Y8o. `Y8 8 8888         
                                     `8.`8'         8 8888         8         `Y8o.` 8         `Y8o.` 8 8888         
                                      `8.`          8 888888888888 8            `Yo 8            `Yo 8 888888888888 



EOF


#################
### VARIABLES ###
#################

PACMAN_PACKAGES=(
### Desktop Environment ###
  i3-gaps
  picom
  feh

### Dev Tools ###
  kitty
  ripgrep
  zsh
  fzf
  tmux
  fd
  bat
  yazi
  lazygit
  neovim
  imagemagick # snacks.image dependency (nvim)
  tree

### CLI tools ###
  btop
  fastfetch
  stow
# tealdeer   # tldr man pages (comes with endeavour)
  yt-dlp   # YouTube (and other sites) to MP3
  jq       # json query (parser)
  yq       # yaml query (parer)
  ffmpeg   # Complete solution to record, convert and stream audio and video
  termusic # music player TUI
  rmpc     # music player TUI (mpd)
  mpc      # mpd client
  id3v2    # cli tool for adding meta data to sound tracks

### Other ###
  mpv
  vlc
  obsidian
  libreoffice
)

YAY_PACKAGES=(
  brave-bin
  kanata
  git-spice-bin
  spotify
  tor-browser-bin
  google-chrome
)

INSTALLER_FLAGS=(
  -S
  --noconfirm
  --noprogressbar
  --needed
  --disable-download-timeout
)

##############################################################

print_section "Installing pacman packages"

echo "Updating pacman repository"
sudo pacman -Syu
for PACKAGE in "${PACMAN_PACKAGES[@]}"; do
  try_install_package sudo pacman "${INSTALLER_FLAGS[@]}" "$PACKAGE"

done

##############################################################

print_section "Installing AUR packages"
for package in "${YAY_PACKAGES[@]}"; do
  try_install_package yay "${INSTALLER_FLAGS[@]}" "$PACKAGE"
done

##############################################################

print_section "Stowing dotfiles"

missing_software_guard "stow"

if stow -n -v .; then
  write_to_log "[INFO] stowed: $(stow -n -v .)"
  stow . >>"$LOG_FILE_PATH" 2>&1
else
  write_to_log "[ERROR] stow conflict detected. Aborting..."
  exit 1
fi

##############################################################

print_section "Bootstrapping ZSH"

missing_software_guard "zsh"

printf "Change login shell"
zsh_path=$(which zsh)
echo "$zsh_path" | sudo tee -a /etc/shells
chsh -s "$zsh_path"
./_bootstrap_zsh.sh

##############################################################

print_section "Setting up services"

./_services.sh

##############################################################

print_section "Fixing miscellaneous stuff"

echo "Install tmux plugins"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
"$HOME"/.tmux/plugins/tpm/scripts/install_plugins.sh

echo "Updating tealdeer cache"
tldr --update

echo "Installing NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

echo "Installing Bun"
curl -fsSL https://bun.sh/install | bash

