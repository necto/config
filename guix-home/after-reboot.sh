#!/bin/bash
# to be run after the reboot when all the guix symlinks are in place
# and guix-home packages installed, and environment is set up
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# install the systemd and xdg-desktop-portal configs for xdg-desktop-portal-wlr
sudo bash ".config/xdg-desktop-portal-wlr-install.sh"

# Refresh all channels, including nonguix that was added by guix-home
# --fallback will make guix build the missing package from source if substitute fails
guix pull --fallback

# Install the common packages from the manifest (e.g., firefox)
guix package -m "$SCRIPT_DIR/manifest.scm"

# Install doom
bash "$HOME/.config/doom/install.sh"

echo "Go to the Bitwarden page to install it interactively"
$HOME/.guix-home/bin/firefox https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/

echo "Go to the Syncthing page to configure the peers"
$HOME/.guix-home/bin/firefox https://localhost:8384
