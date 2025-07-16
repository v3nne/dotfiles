#!/bin/bash
set -euo pipefail

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




YAY_CMD="yay -S --noconfirm --noprogressbar --needed --disable-download-timeout"

$YAY_CMD brave-bin
$YAY_CMD kanata
$YAY_CMD git-spice-bin
$YAY_CMD spotify
$YAY_CMD tor-browser-bin
$YAY_CMD google-chrome







sudo pacman -Syu --noconfirm --needed ansible

# ansible-playbook ~/.bootstrap/setup.yml --ask-become-pass
ansible-playbook ./bootstrap.yml --ask-become-pass




printf "\n\n === Bootstrapping ZSH ===\n\n"
./bootstrap_zsh.sh


printf "\n\n === other stuff ===\n\n"
# Install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
"$HOME"/.tmux/plugins/tpm/scripts/install_plugins.sh

tldr --update

