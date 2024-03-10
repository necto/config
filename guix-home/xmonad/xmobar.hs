Config { font = "xft:Ubuntu-12"
       , additionalFonts = ["xft:Ubuntu Mono-15"]
       , bgColor = "black"
       , fgColor = "grey"
       , position = BottomW R 93
       , commands = [ Run MultiCpu [ "--template" , "<total0>|<total1>|<total2>|<total3>%"
                                   , "--Low"      , "50"         -- units: %
                                   , "--High"     , "85"         -- units: %
                                   , "--low"      , "darkgreen"
                                   , "--normal"   , "darkorange"
                                   , "--high"     , "darkred"
                                   , "-m"         , "2"
                                   ] 10
                    , Run Memory ["-t","<usedratio>%"] 10
                    , Run Date "%a %b %_d %H:%M" "date" 10
                    , Run Com "/bin/bash" ["-c", "~/.xmonad/get-volume"] "myvolume" 10
                    , Run Com "/bin/bash" ["-c", "~/.xmonad/query-keyboard-layout.sh"] "mylayout" 10
                    , Run Battery        [ "--template" , "<acstatus>"
                                         , "--Low"      , "10"        -- units: %
                                         , "--High"     , "80"        -- units: %
                                         , "--low"      , "darkred"
                                         , "--normal"   , "darkorange"
                                         , "--high"     , "darkgreen"

                                         , "--" -- battery specific options
                                         -- discharging status
                                         , "-o"	, "<left>% (<timeleft>)"
                                         -- AC "on" status
                                         , "-O"	, "<fc=#dAA520>Charging</fc>"
                                         -- charged status
                                         , "-i"	, "<fc=#006000>Charged</fc>"
                                         ] 120
                    , Run DynNetwork     [ "--template" , "<tx>kB/s <rx>kB/s"
                                         , "--Low"      , "1000"          -- units: B/s
                                         , "--High"     , "1000000"       -- units: B/s
                                         , "--low"      , "darkgreen"
                                         , "--normal"   , "darkorange"
                                         , "--high"     , "darkred"
                                         ] 10
                    , Run StdinReader
                    , Run Date "<fc=darkorange>%a %b %_d</fc> <fc=green>%H:%M</fc>" "date" 10
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %dynnetwork% | <fc=green>[%mylayout%]</fc><fn=1><%multicpu% : %memory%></fn>| <icon=/home/necto/.xmonad/icons/volume.xbm/> %myvolume% | %battery%  %date%"
       }
