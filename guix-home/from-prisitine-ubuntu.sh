
sudo apt install -y xmonad guix git

# takes long time and can take advantage of many cores
guix pull
guix pull # just to be sure

git clone https://github.com/necto/config

# takes long time and can take advantage of many cores
# FIXME: fails at the end for some reason
# ice-9/boot-9.scm:1685:16: In procedure raise-exception:
# Wrong type to apply: "/usr/bin/env sh"
guix home reconfigure config/guix-home/home-configuration.scm
