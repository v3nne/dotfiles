#!/bin/bash

YAY_CMD="yay -S --noconfirm --noprogressbar --needed --disable-download-timeout"

$YAY_CMD brave-bin
$YAY_CMD kanata
$YAY_CMD git-spice-bin
$YAY_CMD spotify
$YAY_CMD tor-browser-bin
$YAY_CMD google-chrome





# Install javascript stuff
curl -fsSL https://bun.sh/install | bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
