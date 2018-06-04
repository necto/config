OTHER_SCREEN=`xrandr | grep connected | grep -v disconnected | grep -v eDP1 | awk '{print $1}'`; xrandr --output $OTHER_SCREEN --off
