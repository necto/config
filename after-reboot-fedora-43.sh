#!/bin/bash
# to be run after the reboot when all the guix symlinks are in place
# and guix-home packages installed, and environment is set up
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# install the systemd and xdg-desktop-portal configs for xdg-desktop-portal-wlr
# This enables screen sharing in firefox
sudo bash "$HOME/.config/xdg-desktop-portal-wlr-install.sh"

# Refresh all channels, including nonguix that was added by guix-home
# --fallback will make guix build the missing package from source if substitute fails
guix pull --fallback

# Install the common packages from the manifest (e.g., firefox)
guix package -m "$SCRIPT_DIR/manifest.scm"

# Remove previous Emacs config if it exists
# it takes precedence over Doom that is stored in ~/.config/emacs
rm -rf ~/.emacs.d

rm -rf ~/proj # it might have been created by doom-emacs if I run doom-install too soon
mv ~/frame-home-backup-2025.12.20/proj/ ~/
mv ~/frame-home-backup-2025.12.20/finance/ ~/
mv ~/frame-home-backup-2025.12.20/notes/ ~/
mv ~/frame-home-backup-2025.12.20/phone-* ~/
mv ~/frame-home-backup-2025.12.20/Sync/ ~/

# Install doom
bash "$HOME/.config/doom-install.sh"

# Recover Syncthing config and state
pkill -9 syncthing
rm -rf ~/.local/state/syncthing
cp ~/frame-home-backup-2025.12.20/.local/state/syncthing/ ~/.local/state/ -r
syncthing

# Recover ssh keys
rm -rf .ssh/
mv ~/frame-home-backup-2025.12.20/.ssh/ ~/

# TODO: recover firefox sessions

echo "[ ] Go to the Bitwarden page to install it interactively"
$HOME/.guix-profile/bin/firefox https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/

echo "[ ] log-in to bitwarden"
echo "[ ] set auto-lock for 5 minutes"

echo "[ ] Go to the Syncthing page to configure the peers"
$HOME/.guix-profile/bin/firefox https://localhost:8384

echo "[ ] setup wifi"
echo "[ ] add key to github"

echo "[ ] log-in to Copilot 'copilot-login' in emacs"
