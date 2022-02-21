#!/bin/bash

LANG1="us"
LANG2="ru"
CURRENT_LANG=$(setxkbmap -query | grep 'layout' | cut -f6 -d ' ' | cut -f1 -d ',')
if [ "$CURRENT_LANG" = $LANG1 ]; then
    setxkbmap -layout $LANG2,$LANG1
else
    setxkbmap $LANG1
    setxkbmap -option compose:ralt
fi
