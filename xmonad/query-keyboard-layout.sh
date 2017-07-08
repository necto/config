#!/bin/bash

echo $(setxkbmap -query | tail -n 1 | cut -f6 -d ' ')
