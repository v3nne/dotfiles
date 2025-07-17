#!/bin/bash

sudo pacman -S --noconfirm lightdm-webkit2-greeter
yay -S --noconfirm lightdm-webkit-theme-litarvan

mkdir -p "/usr/share/lightdm"
SCRIPT_PATH="/usr/share/lightdm/display-setup.sh"
WALLPAPER_PATH="/usr/share/backgrounds/"

sudo cp "$HOME/dotfiles/_wallpapers/black-lava.jpg" /usr/share/backgrounds
sudo cp -r "$HOME/dotfiles/.icons/Capitaine_Gruvbox_Light" /usr/share/icons/Capitaine_Gruvbox_Light


sudo touch "$SCRIPT_PATH"
sudo tee "$SCRIPT_PATH" <<-EOF
#!/bin/sh

(
  sleep 2
  feh --bg-fill "${WALLPAPER_PATH}"
)&

exit 0
EOF

sudo chown root:lightdm "$SCRIPT_PATH"
sudo chmod 0755 "$SCRIPT_PATH"



sudo tee /etc/lightdm/lightdm.conf.d/10-eos-slick.conf <<-EOF
[LightDM]
logind-check-graphical=true

[Seat:*]
greeter-session=lightdm-webkit2-greeter
allow-user-switching=false
greeter-hide-users=true
greeter-allow-guest=false
allow-guest=false
greeter-setup-script=${SCRIPT_PATH}
EOF



printf "\n\n===You have to manually edit 'greeter-session' to 'lightdm-webkit2-greeter' in '/etc/lightdm/lightdm.conf' ===\n\n"
echo "don't forget to reboot"

