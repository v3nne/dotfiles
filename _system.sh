#!/bin/bash

echo "Fixing slick greeter"
sudo cp "$HOME/dotfiles/_wallpapers/black-lava.jpg" /usr/share/backgrounds
sudo cp -r "$HOME/dotfiles/.icons/Capitaine_Gruvbox_Light" /usr/share/icons/Capitaine_Gruvbox_Light

sudo tee /etc/lightdm/slick-greeter.conf <<'EOF'
[Greeter]
background=/usr/share/backgrounds/black-lava.jpg
draw-user-backgrounds=false
draw-grid=true
theme-name=Gruvbox-Material-Dark
icon-theme-name=oomox-gruvbox-dark
cursor-theme-name=Capitaine_Gruvbox_Light
cursor-theme-size=32
show-a11y=false
show-power=false
background-color=#000000
EOF

