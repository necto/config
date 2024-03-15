
sudo apt install -y xmonad guix git

# takes long time and can take advantage of many cores
guix pull
export GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"
guix pull

git clone https://github.com/necto/config

# takes long time and can take advantage of many cores
# FIXME: fails at the end if I uncomment doom-checkout service
# the substitute* behaves differently when it is invoked from a file loaded from /gnu/store
# and from a file loaded from another place
# ice-9/boot-9.scm:1685:16: In procedure raise-exception:
# Wrong type to apply: "/usr/bin/env sh"
guix home reconfigure config/guix-home/home-configuration.scm
