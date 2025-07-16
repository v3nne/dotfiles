#!/bin/bash

### DONT USE, EXPERIMENTAL PHASE ATM ###

FILE_PATH="/etc/systemd/system/battery-charge-limit.service"

full_name="$0"

# strip directory and “.sh” extension
script_name=$(basename "$full_name" .sh)

echo "This script is named: $script_name"

systemctl daemon-reload
systemctl enable --now battery-charge-limit.service
systemctl start battery-charge-limit.service
systemctl daemon-reload

