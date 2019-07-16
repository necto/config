PRIMARY_SCREEN=$(xrandr | grep primary | awk '{print $1}')
OTHER_SCREEN=`xrandr | grep connected | grep -v disconnected | grep -v $PRIMARY_SCREEN | awk '{print $1}'`
xrandr --output $OTHER_SCREEN --off
