module Ui.Theme exposing
    ( Colors
    , Theme
    , badge
    , badgeError
    , badgeInfo
    , badgeRunning
    , badgeSuccess
    , badgeWarning
    , card
    , cardElevated
    , colors
    , sectionHeader
    , theme
    , toggleTrack
    )

import Element exposing (Element, Attribute, px)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


type alias Theme =
    { colors : Colors
    , spacing : Spacing
    }


type alias Colors =
    { bg : Element.Color
    , surface : Element.Color
    , surfaceElevated : Element.Color
    , surfaceHover : Element.Color
    , border : Element.Color
    , borderSubtle : Element.Color
    , textPrimary : Element.Color
    , textSecondary : Element.Color
    , textMuted : Element.Color
    , accent : Element.Color
    , accentSubtle : Element.Color
    , success : Element.Color
    , successSubtle : Element.Color
    , warning : Element.Color
    , warningSubtle : Element.Color
    , error : Element.Color
    , errorSubtle : Element.Color
    , info : Element.Color
    , infoSubtle : Element.Color
    }


type alias Spacing =
    { xs : Int
    , sm : Int
    , md : Int
    , lg : Int
    , xl : Int
    , xxl : Int
    }


theme : Theme
theme =
    { colors = colors
    , spacing = spacing
    }


colors : Colors
colors =
    { bg = rgb255 10 10 12
    , surface = rgb255 22 27 34
    , surfaceElevated = rgb255 30 37 48
    , surfaceHover = rgb255 36 44 56
    , border = rgb255 48 54 61
    , borderSubtle = rgb255 33 38 45
    , textPrimary = rgb255 230 237 243
    , textSecondary = rgb255 139 148 158
    , textMuted = rgb255 110 118 129
    , accent = rgb255 210 153 34
    , accentSubtle = rgba255 210 153 34 0.15
    , success = rgb255 63 185 80
    , successSubtle = rgba255 63 185 80 0.15
    , warning = rgb255 210 153 34
    , warningSubtle = rgba255 210 153 34 0.15
    , error = rgb255 248 81 73
    , errorSubtle = rgba255 248 81 73 0.15
    , info = rgb255 139 148 158
    , infoSubtle = rgba255 139 148 158 0.15
    }


spacing : Spacing
spacing =
    { xs = 4
    , sm = 8
    , md = 16
    , lg = 24
    , xl = 32
    , xxl = 48
    }


card : List (Attribute msg) -> List (Element msg) -> Element msg
card attrs children =
    Element.column
        ([ Background.color colors.surface
         , Border.rounded 8
         , Border.width 1
         , Border.color colors.borderSubtle
         , Element.paddingXY 24 20
         , Element.spacing 16
         ]
            ++ attrs
        )
        children


cardElevated : List (Attribute msg) -> List (Element msg) -> Element msg
cardElevated attrs children =
    Element.column
        ([ Background.color colors.surfaceElevated
         , Border.rounded 8
         , Border.width 1
         , Border.color colors.borderSubtle
         , Element.paddingXY 24 20
         , Element.spacing 16
         ]
            ++ attrs
        )
        children


sectionHeader : String -> Element msg
sectionHeader title =
    Element.el
        [ Font.size 12
        , Font.color colors.textMuted
        , Font.bold
        , Element.paddingXY 0 4
        ]
        (Element.text (String.toUpper title))


badge : Element.Color -> Element.Color -> List (Attribute msg) -> List (Element msg) -> Element msg
badge bgColor textColor attrs children =
    Element.el
        ([ Background.color bgColor
         , Font.color textColor
         , Element.paddingXY 10 4
         , Border.rounded 9999
         , Font.size 12
         , Font.semiBold
         ]
            ++ attrs
        )
        (Element.row [ Element.spacing 4 ] children)


badgeSuccess : List (Attribute msg) -> List (Element msg) -> Element msg
badgeSuccess attrs children =
    badge colors.successSubtle colors.success attrs children


badgeWarning : List (Attribute msg) -> List (Element msg) -> Element msg
badgeWarning attrs children =
    badge colors.warningSubtle colors.warning attrs children


badgeError : List (Attribute msg) -> List (Element msg) -> Element msg
badgeError attrs children =
    badge colors.errorSubtle colors.error attrs children


badgeRunning : List (Attribute msg) -> List (Element msg) -> Element msg
badgeRunning attrs children =
    badge colors.accentSubtle colors.accent attrs children


badgeInfo : List (Attribute msg) -> List (Element msg) -> Element msg
badgeInfo attrs children =
    badge colors.infoSubtle colors.info attrs children


toggleTrack : Bool -> Element msg
toggleTrack isOn =
    Element.el
        [ Element.width (px 36)
        , Element.height (px 20)
        , Border.rounded 10
        , Background.color
            (if isOn then
                colors.success

             else
                colors.surfaceHover
            )
        , Element.padding 2
        ]
        (Element.el
            [ Element.width (px 16)
            , Element.height (px 16)
            , Border.rounded 8
            , Background.color colors.textPrimary
            , Element.moveRight (if isOn then 16 else 0)
            ]
            Element.none
        )


rgb255 : Int -> Int -> Int -> Element.Color
rgb255 r g b =
    Element.rgb255 r g b


rgba255 : Int -> Int -> Int -> Float -> Element.Color
rgba255 r g b a =
    Element.rgba255 r g b a
