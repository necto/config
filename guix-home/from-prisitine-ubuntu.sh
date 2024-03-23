
set -xeuo pipefail

bash ./framework-ubuntu22-kernel-fixed.sh 

# brightnessctl adds udev rules, so better installed through apt change screen brightness
# swaylock must be installed with the host package manager to collaborate with pam_authenticate
sudo apt install -y guix git swaylock brightnessctl

# add user to the group "video" to allow them to control brightness of the screen
sudo usermod -a -G video necto

# takes long time and can take advantage of many cores
guix pull
echo 'export GUIX_PROFILE="$HOME/.config/guix/current"' >> ~/.profile
echo '. "$GUIX_PROFILE/etc/profile"' >> .. ~/.profile
# Make sure GDM sources the guix paths before starting sway
sudo cp sway.desktop /usr/share/wayland-sessions/sway.desktop 

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


# tip:
# wev - shows the input events (like xev), e.g. key codes



