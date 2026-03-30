#!/bin/bash
case "$1" in
light) SIGNAL=SIGUSR2 ;;
dark) SIGNAL=SIGUSR1 ;;
esac
pkill -u "$USER" --signal=$SIGNAL ^foot$
