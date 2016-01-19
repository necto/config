#!/bin/bash
Y_opt=""
while test $# -gt 0
do
    case "$1" in
        -y | --no-ask | --auto | --yes) Y_opt="-y"
            ;;
        *) echo "unexpected argument $1"
           exit 1
           ;;
    esac
    shift
done
apt-get install $Y_opt software-properties-common
add-apt-repository $Y_opt ppa:ubuntu-elisp
apt-get update
apt-get install $Y_opt emacs-snapshot

