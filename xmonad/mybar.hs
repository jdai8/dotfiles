#!/usr/bin/env runhaskell
-- Polls system info every second and prints to stdout for dzen
-- Speaker/Headphone, Wifi, Battery, Date, Time
import Control.Concurrent (threadDelay)
import Control.Monad (when)
import Data.Time
import Data.List (isInfixOf, intercalate)
import System.Process (readProcess, readCreateProcess, shell)
import System.Environment (getArgs, lookupEnv)
import System.IO (hFlush, stdout)
import Text.Read

data Info = Info
    { audioOn        :: Bool
    , wifiOn         :: Bool
    , batteryPercent :: Int
    , charging       :: Bool
    , date           :: ZonedTime
    }

display :: (Info, Int) -> String
display (info, nMonitors) = intercalate (prettify "" "")
                          $ map snd
                          $ filter (($ info) . fst)

    [ (not.audioOn , prettify "#b58900" "MUTED"       ) -- yellow
    , (not.wifiOn  , prettify "#cb4b16" "NO WIFI" ) -- orange
    , (percentIf   , percentStr                   ) -- cyan/green/red
    , (charging    , prettify "#d33682" "CHARGING") -- magenta
    , (return True , "^pa(" ++ show (rightAlign nMonitors) ++ ")" )
    , (return True , prettify "#6c71c4" dayStr    ) -- light purple
    , (return True , prettify "#268bd2" timeStr   ) -- light blue
    ]

    where percentIf  = (||) <$> charging <*> ((<100) . batteryPercent)
          percentStr = prettify batteryColor (show p ++ "%")
            where p = min 100 $ batteryPercent info
                  batteryColor | p <= 33   = "#cb4b16"
                               | p <= 66   = "#859900"
                               | otherwise = "#2aa198"

          dayStr     = formatTime defaultTimeLocale "%b %-d" $ date info
          timeStr    = formatTime defaultTimeLocale "%-l:%M" $ date info

          color c    = (("^bg(" ++ c ++ ")") ++)
          pad s      = " " ++ s ++ " "
          prettify c = color c . pad

          -- hacky way of right-aligning; use absolute positioning
          rightAlign 2  = 1410 + 10 * nSpaces
          rightAlign _  = 2782 + 22 * nSpaces
          nSpaces = length ("Jan 11" ++ "11:11") - length (dayStr ++ timeStr)

getAudioOn :: String -> IO Bool
getAudioOn control =
    isInfixOf "[on]" <$> readProcess "amixer" ["get", control] ""

getWifi :: IO Bool
getWifi = not <$> isInfixOf "ESSID:off" <$> readProcess "iwconfig" ["wlp2s0"] ""

batteryDir = "/sys/class/power_supply/BAT0/"
getBatteryPercent :: IO Int
getBatteryPercent =
    read <$> filter (/= '\n') <$> readFile (batteryDir ++ "capacity")

-- if status is full, we don't count that as charging
getBatteryCharging :: IO Bool
getBatteryCharging =
    (==) "Charging\n" <$> readFile (batteryDir ++ "status")

getInfo :: IO Info
getInfo = Info <$> getAudioOn "Master"
               <*> getWifi
               <*> getBatteryPercent
               <*> getBatteryCharging
               <*> getZonedTime

-- try getting from env, otherwise grep it ourselves
getNMonitors :: IO Int
getNMonitors = do
    env <- lookupEnv "NMONITORS"
    maybe runShell return (env >>= readMaybe)

    where runShell = read . filter (/= '\n') <$>
            readCreateProcess (shell "xrandr | grep \" connected\" | wc -l") ""

-- in microseconds (e-6)
interval = 1000000

main = do
    info      <- getInfo
    nMonitors <- getNMonitors
    putStrLn $ display (info, nMonitors)
    hFlush stdout
    persist   <- fmap ("-p" `elem`) getArgs
    when persist $ do
        threadDelay interval
        main
