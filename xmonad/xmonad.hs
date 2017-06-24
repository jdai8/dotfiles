import XMonad
import System.Environment
import System.Process (readProcess, readCreateProcess, shell)
import XMonad.Config.Desktop (desktopConfig)
import XMonad.Layout.Spacing (smartSpacing)
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks (manageDocks, avoidStruts, docksEventHook)
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.InsertPosition (insertPosition, Focus(..), Position(..))
import XMonad.Actions.CycleWS
import Graphics.X11.ExtraTypes.XF86
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import Data.Time
import Text.Read (readMaybe)

myLayout = avoidStruts
         $ smartSpacing 2
         $ Tall 1 (3/100) (1/2) ||| noBorders Full

myKeyMappings :: XConfig Layout -> M.Map (ButtonMask, KeySym) (X ())
myKeyMappings config@(XConfig {modMask=modm}) = M.fromList $

    [ ((modm,                 xK_Return), spawn $ terminal config)
    , ((modm .|. shiftMask,   xK_Return), spawn $ terminal config ++ " -e zsh -c 'MYENV=active zsh -i'")

    , ((modm,                 xK_h     ), moveTo Prev NonEmptyWS)
    , ((modm .|. shiftMask,   xK_h     ), shiftToPrev >> prevWS)
    , ((modm,                 xK_l     ), moveTo Next NonEmptyWS)
    , ((modm .|. shiftMask,   xK_l     ), shiftToNext >> nextWS)

    -- use mod+x to close instead of mod+shift+c
    , ((modm              ,   xK_x     ), kill)
    , ((modm .|. shiftMask,   xK_c     ), return ())

    -- mod+w to switch between screens (if there's only two); unmap e and r
    , ((modm,               xK_w), nextScreen)
    , ((modm .|. shiftMask, xK_w), shiftNextScreen)
    , ((modm,               xK_e), return ())
    , ((modm .|. shiftMask, xK_e), return ())
    , ((modm,               xK_r), return ())
    , ((modm .|. shiftMask, xK_r), return ())

    , ((0,    xF86XK_MonBrightnessUp  ), spawn "brightness -inc 10"   )
    , ((0,    xF86XK_MonBrightnessDown), spawn "brightness -dec 10"   )
    , ((0,    xK_Print                ), spawn "snip"                 )
    , ((0,    xF86XK_AudioRaiseVolume ), spawn "amixer set Master 2.5%+")
    , ((0,    xF86XK_AudioLowerVolume ), spawn "amixer set Master 2.5%-")
    , ((0,    xF86XK_AudioMute        ), spawn "amixer set Master 0%" )
    , ((modm, xK_a                    ), spawn toggleAudio)

    , ((modm, xK_c      ), spawn "google-chrome-stable" )
    , ((modm, xK_z      ), spawn "zathura-wrapper.sh"   )
    , ((modm, xK_s      ),
      spawn "kill $(pidof mybar) || mybar -p | dzen2 -ta l -h 50 -fg black -bg black -fn Hack -y 9999")
    ]

toggleAudio = "(amixer get \"Headphone Jack\" | grep \"\\[on\\]\" && " ++
                "amixer set \"Headphone Jack\" off && amixer set Speaker on) || " ++
              "(amixer set \"Headphone Jack\" on && amixer set Speaker off)"

myFocusedColor h | h >= 6 && h < 18 = "#657b83" -- #657b83 looks ok
                 | otherwise        = "#d33682"

-- try getting from env, otherwise grep it ourselves
getNMonitors :: IO Int
getNMonitors = do
    env <- lookupEnv "NMONITORS"
    maybe runShell return (env >>= readMaybe)
    where runShell = read . filter (/= '\n') <$>
            readCreateProcess (shell "xrandr | grep -c \" connected\"") ""

myBorderWidth :: Int -> Dimension
myBorderWidth 1 = 8
myBorderWidth _ = 4

main = do
    -- hour <- read . formatTime defaultTimeLocale "%H" <$> getZonedTime
    nMonitors <- getNMonitors
    xmonad desktopConfig
        { terminal           = "urxvtc"
        , borderWidth        = myBorderWidth nMonitors
        , normalBorderColor  = "#000000"
        , focusedBorderColor = myFocusedColor 10
        , workspaces         = ["1","2","3"]
        , layoutHook         = myLayout
        , keys               = myKeyMappings <+> keys def
        , manageHook         = {--insertPosition Below Newer <+>--} manageDocks
        , handleEventHook    = docksEventHook
        }
