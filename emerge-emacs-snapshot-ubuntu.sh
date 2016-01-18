#!/bin/bash
apt-get install software-properties-common
add-apt-repository -y ppa:ubuntu-elisp
apt-get update
apt-get install emacs-snapshot
