#!/bin/bash
set -euo pipefail

sudo dnf install -y @development-tools zsh git curl file procps-ng clang unzip

sudo usermod -s "$(command -v zsh)" "$(id -un)"
