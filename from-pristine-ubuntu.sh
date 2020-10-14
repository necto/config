
# Docker container to try it out:
# docker run -it -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --user="$(id --user):$(id --group)" ubuntu bash

apt update
apt install -y git python emacs xmonad
# emacs package asks for geographic area: 8.Europe 63.Zurich
git clone https://github.com/necto/config
cd config
./install
