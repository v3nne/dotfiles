#!/bin/bash
set -euo pipefail

sudo dnf install -y tailscale
sudo systemctl enable --now tailscaled
