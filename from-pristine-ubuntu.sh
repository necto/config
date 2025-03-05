#!/bin/bash
# This is the entry point of the bootstrapping process.
# It installs the necessary software and workarounds and passes over to guix home.
# To lunch it, it is enough to fetch just the script file and run it:
# wget https://raw.githubusercontent.com/necto/config/master/from-pristine-ubuntu.sh
# bash from-pristine-ubuntu.sh
set -xeuo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <profile>"
    echo "Available profiles:"
    echo "  - personal"
    echo "  - professional"
    exit 1
fi

PROFILE="$1"

# perform fast "sudo" actions first to avoid password prompt later
sudo apt update

# add user to the group "video" to allow them to control brightness of the screen
sudo usermod -a -G video $USER

# installing
# - guix to manage most of the software
# - git to fetch the config repository initially
# - brightnessctl adds udev rules, so better installed through apt change screen brightness
# - swaylock must be installed with the host package manager to collaborate with pam_authenticate
#   for Ubuntu 22.04:
#   use https://launchpad.net/~pv-safronov/+archive/ubuntu/backports PPA to get a swaylock 1.7 that supports fractional sceen scaling
sudo apt install -y guix git swaylock brightnessctl

# Make sure to clone the entire config repo first
# to enable the later steps copy some files from it.
cd "$HOME"
# Preserve an existing `config` directory if any
if [ -e "$HOME/config" ]; then
    mv "$HOME/config" "$HOME/bkp-config-$(date '+%F-%T')"
fi
git clone https://github.com/necto/config
CONFIG_DIR="$HOME/config"
cd config && git remote set-url origin 'git@github.com:necto/config'

# Make sure GDM sources the guix paths before starting sway
GDM_SWAY_SESSION_FILE="/usr/share/wayland-sessions/sway.desktop"
sudo cp "$CONFIG_DIR/sway.desktop" "$GDM_SWAY_SESSION_FILE"
# Make the shell substitution in the .desktop file
# because GDM might not perform shell substitutions
sudo sed -i "s@\$HOME@$HOME@" "$GDM_SWAY_SESSION_FILE"

# Allow reading from guix store, which contains also configs and stuff like pointer icons.
if [ ! -f /etc/apparmor.d/abstractions/base.d/guix.store.ro ]; then
    sudo mkdir -p /etc/apparmor.d/abstractions/base.d
    sudo cp "$CONFIG_DIR/apparmor-guix.store.ro" /etc/apparmor.d/abstractions/base.d/guix.store.ro
    sudo service apparmor reload
fi

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

# takes a long time and can take advantage of many cores
guix home reconfigure "$CONFIG_DIR/$PROFILE.scm"

echo "Now you can reboot and log into sway."
echo "Then run $CONFIG_DIR/after-reboot.sh"
