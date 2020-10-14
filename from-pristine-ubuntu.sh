
# Docker container to try it out:
# docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --user="$(id --user):$(id --group)" ubuntu bash

ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
DEBIAN_FRONTEND=noninteractive apt update && apt install -y git python emacs xmonad
dpkg-reconfigure --frontend noninteractive tzdata
cd ~
git clone https://github.com/necto/config
cd config
./install
