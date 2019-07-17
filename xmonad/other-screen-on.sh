# Turn on the second screen connected, and position it to the right of
# the primary screen, aligned by the bottom edge.

# If there is no second screen, exit silently

SCREENS_CONNECTED=$(xrandr | grep ' connected' | wc -l)
if [ $SCREENS_CONNECTED \> 2 ];
then
    echo This script does not support more than 2 screens.
    exit 1
fi

if [ 2 \> $SCREENS_CONNECTED ];
then
    # Only one screen is connected, nothing to do here
    exit 0
fi

SELECTED_RES_RX="[0-9]\+x[0-9]\+.*[0-9.]\+[ *]+"
PRIMARY_SCREEN=$(xrandr | grep primary | awk '{print $1}')
OTHER_SCREEN=$(xrandr | grep connected | grep -v disconnected | grep -v $PRIMARY_SCREEN | awk '{print $1}')
PRIMARY_SCREEN_RES=$(xrandr | sed -n "/primary/,/connected/p" | grep "$SELECTED_RES_RX" | awk '{print $1}')
OTHER_SCREEN_RES=$(xrandr | sed -n "/^$OTHER_SCREEN/,/primary/p"  | grep "$SELECTED_RES_RX" | awk '{print $1}')
PRIMARY_SCREEN_RESX=$(echo $PRIMARY_SCREEN_RES | awk -Fx '{print $1}')
PRIMARY_SCREEN_RESY=$(echo $PRIMARY_SCREEN_RES | awk -Fx '{print $2}')
OTHER_SCREEN_RESX=$(echo $OTHER_SCREEN_RES | awk -Fx '{print $1}')
OTHER_SCREEN_RESY=$(echo $OTHER_SCREEN_RES | awk -Fx '{print $2}')

if [ $OTHER_SCREEN_RESY \> $PRIMARY_SCREEN_RESY ];
then
    PRIMARY_POSX=0
    PRIMARY_POSY=$(($OTHER_SCREEN_RESY-$PRIMARY_SCREEN_RESY))
    OTHER_SCREEN_POSX=$PRIMARY_SCREEN_RESX
    OTHER_SCREEN_POSY=0

    # Order is important!
    xrandr --output $OTHER_SCREEN --auto --pos ${OTHER_SCREEN_POSX}x${OTHER_SCREEN_POSY}
    xrandr --output $PRIMARY_SCREEN --pos ${PRIMARY_POSX}x${PRIMARY_POSY}
else
    PRIMARY_POSX=0
    PRIMARY_POSY=0
    OTHER_SCREEN_POSX=$PRIMARY_SCREEN_RESX
    OTHER_SCREEN_POSY=$(($PRIMARY_SCREEN_RESY-$OTHER_SCREEN_RESY))

    
    xrandr --output $OTHER_SCREEN --auto --pos ${OTHER_SCREEN_POSX}x${OTHER_SCREEN_POSY}
fi


#OTHER_SCREEN=`xrandr | grep connected | grep -v disconnected | grep -v eDP1 | awk '{print $1}'`; xrandr --output $OTHER_SCREEN --auto --right-of eDP1
