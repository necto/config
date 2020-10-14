cp from-pristine-ubuntu.sh docker-x11
docker build -t x11-on ./docker-x11
Xnest :1 -ac &
docker run -it --env=DISPLAY=":1" -v /tmp/.X11-unix:/tmp/.X11-unix x11-on bash

# if X forwarding fails, try this:
# xhost +
# docker run -it --runtime=runc -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix x11-on bash
