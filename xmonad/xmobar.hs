Config { font = "xft:Ubuntu-10"
       , additionalFonts = ["xft:Ubuntu Mono-11"]
       , bgColor = "black"
       , fgColor = "grey"
       , position = TopW L 93
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
                    , Run Battery        [ "--template" , "Batt: <acstatus>"
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
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ [%mylayout%] <fn=1><%multicpu% : %memory%> </fn> | Vol: %myvolume% | %battery%  <fc=#ee9a00>%date%</fc>"
       }
