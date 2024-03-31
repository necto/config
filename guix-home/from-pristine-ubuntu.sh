#!/bin/bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# perform fast "sudo" actions first to avoid password prompt later
sudo apt update

# add user to the group "video" to allow them to control brightness of the screen
sudo usermod -a -G video $USER

# Make sure GDM sources the guix paths before starting sway
GDM_SWAY_SESSION_FILE="/usr/share/wayland-sessions/sway.desktop"
sudo cp "$SCRIPT_DIR/sway.desktop" "$GDM_SWAY_SESSION_FILE"
# Make the shell substitution in the .desktop file
# because GDM might not perform shell substitutions
sudo sed -i "s@\$HOME@$HOME@" "$GDM_SWAY_SESSION_FILE"

# installing
# - guix to manage most of the software
# - git to fetch the config repository initially
# - brightnessctl adds udev rules, so better installed through apt change screen brightness
# - swaylock must be installed with the host package manager to collaborate with pam_authenticate
sudo apt install -y guix git swaylock brightnessctl

# workaround for https://gitlab.gnome.org/GNOME/xdg-desktop-portal-gnome/-/issues/74
# see also https://bbs.archlinux.org/viewtopic.php?id=285590
systemctl --user mask xdg-desktop-portal-gtk
systemctl --user mask xdg-desktop-portal-gnome

# takes a long time and can take advantage of many cores
# --fallback will make guix build the missing package from source if substitute fails
guix pull --fallback
GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
# make sure the new guix is used
hash -r
guix pull --fallback

cd "$HOME"

git clone https://github.com/necto/config

cd config && git remote set-url origin 'git@github.com:necto/config'

# takes a long time and can take advantage of many cores
guix home reconfigure "$HOME/config/guix-home/home-configuration.scm"

echo "Now you can reboot and log into sway."
echo "Then run $SCRIPT_DIR/after-reboot.sh"
