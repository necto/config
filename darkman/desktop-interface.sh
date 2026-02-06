#!/bin/bash
case "$1" in
dark) SCHEME='prefer-dark' ;;
light) SCHEME='default' ;;
esac
gsettings set org.gnome.desktop.interface color-scheme $SCHEME
