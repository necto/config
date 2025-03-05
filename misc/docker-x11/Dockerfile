FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y sudo

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    groupadd --gid ${gid} developer && \
    useradd --create-home --no-log-init --shell /bin/bash --uid ${uid} --gid ${gid} developer && \
    echo 'developer:a' | chpasswd && \   
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

COPY from-pristine-ubuntu.sh /home/developer/from-pristine-ubuntu.sh

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

CMD xclock
