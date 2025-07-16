# Installing kanata
yay -S --noconfirm kanata

# Give your user access to the uinput subsystem
sudo groupadd uinput                 # only if the group doesn't already exist  
sudo usermod -aG input,uinput "$USER"  # add yourself to both groups  


sudo tee /etc/udev/rules.d/99-uinput.rules <<'EOF'
Grant uinput group access to /dev/uinput
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

# Reload and trigger udev
sudo udevadm control --reload-rules
sudo udevadm trigger # might need to add `--action=add /dev/uinput`

# (Re)load the kernel module
sudo modprobe -r uinput
sudo modprobe uinput

# Reload your user-systemd units and enable Kanata
systemctl --user daemon-reload
systemctl --user enable --now kanata.service


