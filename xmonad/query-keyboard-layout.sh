#!/bin/bash

echo $(setxkbmap -query | grep 'layout' | cut -f6 -d ' ' | cut -f1 -d ',')
