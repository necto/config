#!/bin/bash
set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# installing
# - guix to manage most of the software
# - git to fetch the config repository initially
# - brightnessctl adds udev rules, so better installed through apt change screen brightness
# - swaylock must be installed with the host package manager to collaborate with pam_authenticate
sudo apt install -y guix git swaylock brightnessctl

# add user to the group "video" to allow them to control brightness of the screen
sudo usermod -a -G video necto

# Make sure GDM sources the guix paths before starting sway
sudo cp "$SCRIPT_DIR/sway.desktop" /usr/share/wayland-sessions/sway.desktop

# takes long time and can take advantage of many cores
guix pull
GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
# make sure the new guix is used
hash -r
guix pull

cd "$HOME"

git clone https://github.com/necto/config

# takes long time and can take advantage of many cores
# FIXME: fails at the end if I uncomment doom-checkout service
# the substitute* behaves differently when it is invoked from a file loaded from /gnu/store
# and from a file loaded from another place
# ice-9/boot-9.scm:1685:16: In procedure raise-exception:
# Wrong type to apply: "/usr/bin/env sh"
guix home reconfigure config/guix-home/home-configuration.scm
