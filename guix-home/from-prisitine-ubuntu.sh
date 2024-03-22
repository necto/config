
set -euo pipefail

sudo apt install -y guix git sway

# takes long time and can take advantage of many cores
guix pull
echo 'export GUIX_PROFILE="$HOME/.config/guix/current"' >> ~/.profile
echo '. "$GUIX_PROFILE/etc/profile"' >> .. ~/.profile
# Make sure GDM sources the guix paths before starting sway
# TODO: as you are already modifying the .desktop file, why not install sway from guix too?
# Here is the full /usr/share/wayland-sessions/sway.desktop:
#
# [Desktop Entry]
# Name=Sway
# Comment=An i3-compatible Wayland compositor
# Exec=/usr/bin/bash -l -c sway
# Type=Application
#
sudo sed -i 's:Exec=sway:Exec=/usr/bin/bash -l -c sway:' /usr/share/wayland-sessions/sway.desktop

# restart
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


# unordered continuation

# to be able to lock screen
# maybe available on guix
sudo apt install swaylock

# control screen color temperature according to time of the day
# maybe available on guix
sudo apt install gammastep

# tip:
# wev - shows the input events (like xev), e.g. key codes

# change screen brightness
# maybe available on guix
sudo apt install brightnessctl
# add user to the group "video" to allow them to control brightness of the screen
sudo usermod -a -G video necto


