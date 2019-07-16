import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.NoBorders
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.SpawnOnce
import Graphics.X11.ExtraTypes.XF86
import Graphics.X11.Types
import XMonad.Actions.CycleWS
import System.IO

import qualified XMonad.StackSet as W
import qualified XMonad.Layout.IndependentScreens as LIS

-- A "light" (http://haikarainen.github.io/light/) utility is
-- assumed to be in my $PATH, in order to control the backlight brightness.
-- (as xbacklight suddenly stopped working for some reason)

togglevga = do
  screencount <- LIS.countScreens
  if screencount > 1
    then spawn "bash ~/.xmonad/other-screen-off.sh"
    else spawn "bash ~/.xmonad/other-screen-on.sh"

-- Does not quite work for now: when called
-- many times in a row, places all the windows in to the
-- last workspace
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
  spawn program
  windows $ W.greedyView workspace

-- | Startup applications
startupHook' :: X()
startupHook' = do
  spawnOnce "try arbtt-capture -r 30"

main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmonad $ ewmh $ docks defaultConfig
    { manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = smartBorders . avoidStruts $ layoutHook defaultConfig
    , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 100
                , ppUrgent = xmobarColor "yellow" "red" . xmobarStrip}
    , modMask = mod4Mask
    , borderWidth = 2
    , handleEventHook = handleEventHook def <+> fullscreenEventHook
    , startupHook = startupHook'
    } `additionalKeys`
    [ ((mod4Mask .|. shiftMask, xK_z ), spawn "xscreensaver-command -lock")
    , ((0, xK_Print           ), spawn "~/.xmonad/switch_keyboard_layout.sh")
    , ((0, xK_Menu           ), spawn "~/.xmonad/switch_keyboard_layout.sh")
    , ((0, xF86XK_AudioLowerVolume   ), spawn "amixer set Master 2-")
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "amixer set Master 2+")
    , ((0, xF86XK_AudioMute          ), spawn "amixer set Master toggle && amixer set Speaker unmute && amixer set Headphone unmute")
    , ((0, 0x1008ffb2{-xF86AudioMicMute-} ), spawn "amixer set Capture toggle")
    , ((0, xK_KP_Right                  ), spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
    , ((0, xK_KP_Left                   ), spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
    , ((0, xK_KP_Begin                  ), spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
    , ((0, xF86XK_MonBrightnessUp    ), spawn "light -A 7")
    , ((0, xF86XK_MonBrightnessDown  ), spawn "light -U 5")
    , ((mod4Mask, xK_b               ), sendMessage ToggleStruts)
    , ((mod4Mask, xK_s               ), do
          spawnToWorkspace "thunderbird" "5"
          spawnToWorkspace "firefox" "2"
          spawnToWorkspace "skypeforlinux" "6"
          spawnToWorkspace "telegram" "6"
          spawnToWorkspace "slack" "6")
    , ((0, xF86XK_Display            ), togglevga)
    , ((mod4Mask, xK_p               ), spawn "dmenu_run -fn 'Ubuntu Mono-30'")

    , ((mod4Mask, xK_Down            ), nextScreen)
    , ((mod4Mask .|. shiftMask, xK_Down), shiftNextScreen)
    , ((mod4Mask, xK_Up), prevScreen )
    , ((mod4Mask .|. shiftMask, xK_Up), shiftPrevScreen)

    , ((mod4Mask, xK_Left), prevWS   )
    , ((mod4Mask .|. shiftMask, xK_Left), shiftToPrev)
    , ((mod4Mask, xK_Right), nextWS  )
    , ((mod4Mask .|. shiftMask, xK_Right), shiftToNext)
    ]

