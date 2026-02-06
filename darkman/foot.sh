#!/bin/bash
case "$1" in
light) SIGNAL=SIGUSR1 ;;
dark) SIGNAL=SIGUSR2 ;;
esac
pkill -u "$USER" --signal=$SIGNAL ^foot$
