module Lib.Date exposing
    ( formatDateTime
    , formatRelative
    , formatDuration
    )

import Data.Health exposing (Posix)
import Time


posixToMillis : Posix -> Int
posixToMillis posix =
    posix * 1000


toTime : Posix -> Time.Posix
toTime posix =
    Time.millisToPosix (posixToMillis posix)


formatDateTime : Posix -> String
formatDateTime posix =
    let
        time = toTime posix
        zone = Time.utc
        year = Time.toYear zone time
        month = Time.toMonth zone time
        day = Time.toDay zone time
        hour = Time.toHour zone time
        minute = Time.toMinute zone time
        second = Time.toSecond zone time
    in
    String.fromInt year ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt (monthToInt month)) ++ "-"
        ++ String.padLeft 2 '0' (String.fromInt day) ++ " "
        ++ String.padLeft 2 '0' (String.fromInt hour) ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt minute) ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt second)


monthToInt : Time.Month -> Int
monthToInt month =
    case month of
        Time.Jan -> 1
        Time.Feb -> 2
        Time.Mar -> 3
        Time.Apr -> 4
        Time.May -> 5
        Time.Jun -> 6
        Time.Jul -> 7
        Time.Aug -> 8
        Time.Sep -> 9
        Time.Oct -> 10
        Time.Nov -> 11
        Time.Dec -> 12


formatRelative : Posix -> Posix -> String
formatRelative now posix =
    let
        diff = now - posix
        absDiff = abs diff
    in
    if absDiff < 60 then
        "just now"
    else if absDiff < 3600 then
        let
            mins = absDiff // 60
        in
        if diff > 0 then
            String.fromInt mins ++ "m ago"
        else
            "in " ++ String.fromInt mins ++ "m"
    else if absDiff < 86400 then
        let
            hours = absDiff // 3600
        in
        if diff > 0 then
            String.fromInt hours ++ "h ago"
        else
            "in " ++ String.fromInt hours ++ "h"
    else
        let
            days = absDiff // 86400
        in
        if diff > 0 then
            String.fromInt days ++ "d ago"
        else
            "in " ++ String.fromInt days ++ "d"


formatDuration : Maybe Int -> String
formatDuration maybeSeconds =
    case maybeSeconds of
        Nothing ->
            "--:--"

        Just seconds ->
            let
                hours = seconds // 3600
                mins = remainderBy 3600 seconds // 60
                secs = remainderBy 60 seconds
            in
            if hours > 0 then
                String.fromInt hours ++ "h " ++ String.fromInt mins ++ "m"
            else if mins > 0 then
                String.fromInt mins ++ "m " ++ String.fromInt secs ++ "s"
            else
                String.fromInt secs ++ "s"