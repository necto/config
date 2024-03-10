#!/bin/bash
# 20120920 Brian K. White <brian@aljex.com>
#h xbl - Use xrandr or sysfs to set backlight brightness.
#h v 2.2
#h
# For whatever reason, neither xbacklight nor e17's backlight module works
# on my laptop, yet both:
#   "xrandr --output LVDS-0 --set backlight <0-100>"
# and
#   "echo <0-100> > /sys/class/backlight/psb-bl/backlight"
# DO work. So this uses xrandr or sysfs to query and control the backlight.
#
#h Usage:
#h xbl      # Display a slider. Requires the program "zenity".
#h xbl +    # Increase brightness by 1/8 of total range.
#h xbl -    # Decrease brightness by 1/8 of total range.
#h xbl <N>  # Set brightness to N percent (0-100).
#h
#h Environment variables:
#h XBL_STEPS - sets the number of levels or steps from min to max
#h for the +/- keybinding options. Default is 8 if unset.
#h
#h XBL_NOTIFY - true/false - Sets whether or not to generate a desktop
#h notification for each event. Default is true if unset.
#h
#h XBL_METHOD - "xrandr" or "sysfs" - Sets which interface to use. If using
#h sysfs, you will usually also need to install a udev rule to set permissions
#h on the sysfs backlight file so that the user can write to it. (see below)
#h Default is xrandr because it's automatic, doesn't require special
#h udev rules, and doesn't require the user to know the sysfs directory name.
#h
#h XBL_SYSFS_DIR - If using sysfs, sets the /sys/class/backlight/* directory name.
#h If using sysfs, and XBL_SYSFS_DIR is either not specified, or no such directory
#h actually exists, the user is prompted interactively to select one of the
#h existing directories. Example, if your directory is /sys/class/backlight/psb-bl
#h then use XBL_SYSFS_DIR=psb-bl
#h
#h XBL_XRANDR_OUT - Override autodetection of xrandr output name and specify
#h one manually. This script only exists in the first place because at least two
#h other utilities (Enlightenment's backlight module and the xbacklight program)
#h already try to do the same thing as this script, fail to do so automatically,
#h and offer no way for the user to specify manually that which they fail to do
#h automatically. Default is autodetected. A typical example is "LVDS-0".
#h Use "xrandr --prop" or "xrandr --verbose" to find yours.
#h
#h XBL_CFG - Path/name of config file to use. Default is ~/.xbl
#h
#h Any or all of these variables may be defined in the config file or
#h in the environment or omitted altogether. Likewise the config file itself is
#h optional. If no variables are set and no config file exists, xrandr
#h will be used since it's more automatic and doesn't require the user to know
#h any driver/directory/output names, and doesn't require special permissions
#h or the udev rule to set the special permissions.
#h
#h If using sysfs, create this udev rules file and reboot.
#h (everything after SUBSYSTEM is one long line)
#h /etc/udev/rules.d/backlight-permissions.rules:
#h # Allow users to write to sysfs backlight control files
#h # 20120913 Brian K. White <brian@aljex.com>
#h SUBSYSTEM=="backlight",RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power",RUN+="/bin/chmod 664 /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power"
#h
#h Example: Reduce brightness by 1/3, and don't generate a notification:
#h XBL_STEPS=3 XBL_NOTIFY=false xbl -
#h

# How many steps do you want from min to max for the +/- keybindings ?
# Default 8. Parent environment overrides.
: ${XBL_STEPS:=15}

# Generate a desktop notification for each event? (true/false, yes/no, 0/1)
# Default true. Parent environment overrides.
: ${XBL_NOTIFY:=false}

# Use xrandr or use sysfs?
: ${XBL_METHOD:=xrandr}

# Config file
: ${XBL_CFG:=~/.xbl}

# Sysfs backlight directory name. Normally set this in your own ~/.xbl
# config file or on the commandline, not hard-coded here.
# This is only used in sysfs mode.
 XBL_SYSFS_DIR=intel_backlight

# Xrandr output name. Normally allow this to autodetect, or set in your own
# ~/.xbl config file, or on the commandline, not hard-coded here.
# This is only used in xrandr mode.
# XBL_XRANDR_OUT=LVDS-0

###############################################################################
[[ -s $XBL_CFG ]] && . $XBL_CFG
typeset -i INC=$XBL_STEPS MIN MAX OLD NEW

# Query backlight using xrandr
get_xrandr () {
 local u=$XBL_XRANDR_OUT o c l h r x
 xrandr --prop | while read -a x ; do
  [[ -z "$u" && "${x[1]}" == "connected" ]] || [[ "$u" && "${x[0]}" == "$u" ]] && o=${x[0]}
  [[ "$o" && "${x[0]}" == "backlight:" ]] && { c=${x[1]} r=${x[4]//[\()]} l=${r%,*} h=${r#*,} ; }
  [[ "$o" && "$c" && "$l" && "$h" ]] || continue
  echo "OUT=$o OLD=$c MIN=$l MAX=$h"
  break
 done
}

# Query backlight using sysfs
get_sysfs () {
 local o=$XBL_SYSFS_DIR s=/sys/class/backlight d l c h
 d=${s}/$o
 [[ -w ${d}/brightness ]] || {
  cd $s || exit 1
  shopt -s nullglob
  for d in * ;do l+=" FALSE $d" ;done
  o=`zenity --list --radiolist --text="Select Driver" --hide-header --column= --column= $l`
  d=${s}/$o
 }
 read c < ${d}/actual_brightness
 read h < ${d}/max_brightness
 [[ "$o" && "$c" && "$h" ]] || exit 1
 echo "OUT=${d}/brightness OLD=$c MIN=0 MAX=$h"
}

# Set backlight using xrandr
set_xrandr () { xrandr --output $1 --set backlight $2 ; }

# Set backlight using sysfs
set_sysfs () { echo "$2" > $1 ; }

# Sanity check user input
case "$XBL_METHOD" in "xrandr"|"sysfs") : ;; *) exit 1 ;; esac

# Get the current output name, and min, max, & current brightness values. 
eval `get_$XBL_METHOD`

# Prevent uglier errors later if get_* failed.
[[ "$OUT" ]] || echo "No valid xrandr output or sysfs directory."
[[ "$MIN" ]] || echo "Could not find minimum backlight value."
[[ "$MAX" ]] || echo "Could not find maximum backlight value."
[[ "$OLD" ]] || echo "Could not find current backlight value."
[[ "$OUT" && "$MIN" && "$MAX" && "$OLD" ]] || {
 echo "Output:\"$OUT\" Min:\"$MIN\" Max:\"$MAX\" Old:\"$OLD\""
 set |grep '^XBL_'
 exit 1
}

# Determine new brightness level.
# Increment 1/n, Decrement 1/n, Set to arbitrary percent, or Display slider.
case "$1" in
 "-"|"+") NEW=$((OLD$1($MAX-$MIN)/$INC)) ;;
 [0-9]*) NEW=$(($1*$MAX/100)) ;;
 "") NEW=`zenity --scale --title=Backlight --text=Backlight --min-value=$MIN --max-value=$MAX --value=$OLD` ;;
 -h|--help) awk -v s=${0##*/} '($1=="#h"){$1="";gsub("\\<xbl\\>",s);;print $0}' $0 ; exit 0 ;;
 *) echo "Usage: ${0##*/} [-h|--help|+|-|<percent>]" ; exit 1 ; ;;
esac

# Sanity-check user input
[[ $NEW -gt $MAX ]] && NEW=$MAX
[[ $NEW -lt $MIN ]] && NEW=$MIN
case "$XBL_NOTIFY" in
 0|[Nn]*|[Ff]*) XBL_NOTIFY=false ;;
 *) XBL_NOTIFY=true ;;
esac

echo "Output:$OUT Min:$MIN Max:$MAX Old:$OLD New:$NEW"

# Display notification, useful for feedback about keybinding events.
$XBL_NOTIFY && zenity --notification --text="Backlight ${NEW}%" --timeout=1 &

# Set the new backlight level.
set_$XBL_METHOD $OUT $NEW
