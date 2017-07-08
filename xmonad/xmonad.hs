import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.NoBorders
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Types
import XMonad.Actions.CycleWS
import System.IO

import qualified XMonad.StackSet as W
import qualified XMonad.Layout.IndependentScreens as LIS

-- A "light" (http://haikarainen.github.io/light/) utility is
-- assumed to be in my $PATH, in order to control the backlight brightness.
-- (as xbacklight suddenly stopped working for some reason)

-- TODO: detect the real output for the connected monitor.
togglevga = do
  screencount <- LIS.countScreens
  if screencount > 1
    then spawn "xrandr --output HDMI2 --off"
    else spawn "xrandr --output HDMI2 --auto --right-of eDP1"
-- then spawn "xrandr --output HDMI2 --off --output DP1 --off"
-- else spawn "xrandr --output HDMI2 --auto --right-of eDP1 --output DP1 --off"

-- Does not quite work for now: when called
-- many times in a row, places all the windows in to the
-- last workspace
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
  spawn program
  windows $ W.greedyView workspace

main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmonad $ defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = smartBorders . avoidStruts $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 100
                , ppUrgent = xmobarColor "yellow" "red" . xmobarStrip}
    , modMask = mod4Mask
    , borderWidth = 2
    } `additionalKeys`
    [ ((mod4Mask .|. shiftMask, xK_z ), spawn "xscreensaver-command -lock")
    , ((0, xK_Print           ), spawn "~/.xmonad/switch_keyboard_layout.sh")
    , ((0, xF86XK_AudioLowerVolume   ), spawn "amixer set Master 2-")
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "amixer set Master 2+")
    , ((0, xF86XK_AudioMute          ), spawn "amixer set Master toggle && amixer set Speaker unmute && amixer set Headphone unmute")
    , ((0, 0x1008ffb2{-xF86AudioMicMute-} ), spawn "amixer set Capture toggle")
    , ((0, xF86XK_MonBrightnessUp    ), spawn "light -A 7")
    , ((0, xF86XK_MonBrightnessDown  ), spawn "light -U 5")
    , ((mod4Mask, xK_b               ), sendMessage ToggleStruts)
    , ((mod4Mask, xK_s               ), do
          spawnToWorkspace "thunderbird" "5"
          spawnToWorkspace "firefox" "2"
          spawnToWorkspace "skype" "6"
          spawnToWorkspace "telegram" "6"
          spawnToWorkspace "slack" "6")
    , ((0, xF86XK_Display            ), togglevga)

    , ((mod4Mask, xK_Down            ), nextScreen)
    , ((mod4Mask .|. shiftMask, xK_Down), shiftNextScreen)
    , ((mod4Mask, xK_Up), prevScreen )
    , ((mod4Mask .|. shiftMask, xK_Up), shiftPrevScreen)

    , ((mod4Mask, xK_Left), prevWS   )
    , ((mod4Mask .|. shiftMask, xK_Left), shiftToPrev)
    , ((mod4Mask, xK_Right), nextWS  )
    , ((mod4Mask .|. shiftMask, xK_Right), shiftToNext)
    ]

