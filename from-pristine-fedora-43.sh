#!/bin/bash
# This is the entry point of the bootstrapping process.
# It installs the necessary software and workarounds and passes over to guix home.
# To lunch it, it is enough to fetch just the script file and run it:
#   wget https://raw.githubusercontent.com/necto/config/master/from-pristine-fedora-43.sh
# I have not tried to run it in batch mode, so perhaps just copy each command into shell, one by one, or by blocks.
sudo dnf update

# mount the storage with backed-up home dir, then
cp /run/media/necto/offline-backup/frame-home-backup-2025.12.20/ ~/ -r

# set the familiar hostname
sudo hostname frame

# enable the user to control screen brightness
sudo usermod -a -G video $USER

# the following  does not work because git is already installed, and guix is not in the dnf repository:
# sudo dnf install -y guix git swaylock brightnessctl

# swaylock and brightnessctl must be installed with the host package manager
# because they need integration with the system
sudo dnf install -y swaylock brightnessctl network-manager-applet

# Now install guix using their official install script
cd /tmp
wget https://codeberg.org/guix/guix/raw/commit/3c81c4b8b8a4f6d28faf540d7fa5c36772be15fc/etc/guix-install.sh
# approve a couple of PGP keys:
# key 27D586A4F8900854329FF09F1260E46482E63562
# key 3CE464558A84FDC69DB40CFB090B11993D9AEBB5
sudo bash ./guix-install.sh

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

# skip sway desktop file, I don't use sway anylonger

# Make sure GDM sources the guix paths before starting sway
GDM_NIRI_SESSION_FILE="/usr/share/wayland-sessions/niri.desktop"
sudo cp "$CONFIG_DIR/niri.desktop" "$GDM_NIRI_SESSION_FILE"
# Make the shell substitution in the .desktop file
# because GDM might not perform shell substitutions
sudo sed -i "s@\$HOME@$HOME@" "$GDM_NIRI_SESSION_FILE"

# skip apparmor permission, there seems to be no /etc/apparmor.d in the default fedora installation

# skip the workaround for xdg-desktop-portal-gnome. see from-pristine-ubuntu.sh in case waybar hangs

# Even though guix tries to configure SELinux policy, it still fails to remount /gnu/store writeable
# I tried a few fixes proposed by chatgpt and random internet users, none worked. example:
# sudo semodule -i /var/guix/profiles/per-user/root/current-guix/share/selinux/guix-daemon.cil
# sudo mount -o remount,rw /gnu/store
# sudo restorecon -R /gnu /var/guix
# sudo systemctl restart guix-daemon
# ^^^^^ that stopped working after reboot

# a less secure but more robust fix - disable SELinux but not entirely,
# just for guix-daemon (needs remonting /gnu/store, dnsresolve, etc.)
sudo semanage fcontext -a -t unconfined_exec_t /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon
sudo restorecon -v /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon
sudo systemctl daemon-reload
sudo systemctl restart guix-daemon

# And enable remounting of /gno/store as writeable
# this is a separate SELinux defense applied to a file path, rather than to a process.
sudo semanage fcontext -a -t usr_t "/gnu(/.*)?"
sudo systemctl stop guix-daemon
sudo mount -o remount,rw /gnu/store
mount | grep /gnu/store # verify it has rw label
sudo restorecon -Rv /gnu
ls -Zd /gnu /gnu/store # verify it is "unconfined_u"
sudo systemctl start guix-daemon
ps -eZ | grep guix-daemon # verify it is "unconfined_service_t"

# Add substitute servers and authorize their keys
# helps skipping building firefox
sudo bash "$CONFIG_DIR/add-nonguix-substitutes.sh"

guix pull --fallback --channels="$CONFIG_DIR/guix/channels.scm"

GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
# make sure the new guix is used
hash -r

PROFILE=personal # professional is not relevant as I do not use Fedora at work
# takes a long time and can take advantage of many cores
guix home reconfigure "$CONFIG_DIR/$PROFILE.scm"
guix pull --fallback

echo "Now you can reboot and log into niri."
echo "Then run $CONFIG_DIR/after-reboot-fedora-43.sh"


