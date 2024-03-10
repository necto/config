#!/usr/bin/env bash

# Tested on: Ubuntu 22.04.
# https://askubuntu.com/questions/884534/how-to-run-ubuntu-16-04-desktop-on-qemu/1046792#1046792

set -eux

# Parameters.
id=ubuntu-22.04.4-desktop-amd64
disk_img="${id}.img.qcow2"
disk_img_snapshot="${id}.snapshot.qcow2"
iso="${id}.iso"

# Get image.
if [ ! -f "$iso" ]; then
  echo "download go to https://ubuntu.com/download/desktop/thank-you?version=22.04.4&architecture=amd64 and download $iso" 
  exit 1
  #wget "http://releases.ubuntu.com/18.04/${iso}"
fi

# Go through installer manually.
if [ ! -f "$disk_img" ]; then
  qemu-img create -f qcow2 "$disk_img" 1T
  qemu-system-x86_64 \
    -cdrom "$iso" \
    -drive "file=${disk_img},format=qcow2" \
    -enable-kvm \
    -m 2G \
    -smp 2 \
  ;
fi

# Snapshot the installation.
if [ ! -f "$disk_img_snapshot" ]; then
  qemu-img \
    create \
    -b "$disk_img" \
    -f qcow2 \
    -F qcow2 \
    "$disk_img_snapshot" \
  ;
fi

# Run the installed image.
qemu-system-x86_64 \
  -drive "file=${disk_img_snapshot},format=qcow2" \
  -enable-kvm \
  -m 8G \
  -smp 8 \
  -vga virtio \
  "$@" \
;
