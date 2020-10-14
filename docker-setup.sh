# Docker setup
sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# if X forwarding fails, try this:
# xhost +
# docker run --rm --runtime=runc --interactive --env=DISPLAY=$DISPLAY --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw sshipway/xclock

sudo apt install -y xnest
