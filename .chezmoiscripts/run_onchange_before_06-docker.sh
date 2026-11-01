#!/bin/bash
set -euo pipefail

# addrepo fails if the repo file already exists
if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
fi

sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "$(id -un)"
