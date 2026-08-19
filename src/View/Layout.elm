module View.Layout exposing
    ( view
    )

import Element exposing (Element, px)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Ui.Theme exposing (colors)


view : { title : String, subtitle : String, healthStatus : String, isHealthy : Bool, windowWidth : Int, children : List (Element msg) } -> Element msg
view { title, subtitle, healthStatus, isHealthy, windowWidth, children } =
    let
        isMobile =
            windowWidth < 640

        contentPadding =
            if isMobile then
                { x = 16, y = 16 }

            else
                { x = 32, y = 32 }

        sectionSpacing =
            if isMobile then
                16

            else
                24
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.spacing 0
        ]
        [ header title subtitle healthStatus isHealthy isMobile
        , Element.el
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.paddingXY contentPadding.x contentPadding.y
            ]
            (Element.column
                [ Element.spacing sectionSpacing
                , Element.width Element.fill
                , Element.height Element.fill
                ]
                children
            )
        ]


header : String -> String -> String -> Bool -> Bool -> Element msg
header title subtitle healthStatus isHealthy isMobile =
    let
        headerPadding =
            if isMobile then
                { x = 16, y = 12 }

            else
                { x = 32, y = 16 }

        titleSize =
            if isMobile then
                14

            else
                16

        subtitleSize =
            if isMobile then
                11

            else
                13
    in
    Element.el
        [ Element.width Element.fill
        , Background.color colors.surface
        , Border.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
        , Border.color colors.borderSubtle
        ]
        (Element.row
            [ Element.width Element.fill
            , Element.paddingXY headerPadding.x headerPadding.y
            , Element.spacing 16
            , Element.centerY
            ]
            [ Element.column
                [ Element.spacing 2
                ]
                [ Element.el
                    [ Font.size titleSize
                    , Font.semiBold
                    , Font.color colors.textPrimary
                    ]
                    (Element.text title)
                , Element.el
                    [ Font.size subtitleSize
                    , Font.color colors.textMuted
                    ]
                    (Element.text subtitle)
                ]
            , Element.el [ Element.width Element.fill ] Element.none
            , healthPill healthStatus isHealthy isMobile
            ]
        )


healthPill : String -> Bool -> Bool -> Element msg
healthPill status isHealthy isMobile =
    let
        pillPadding =
            if isMobile then
                { x = 8, y = 4 }

            else
                { x = 10, y = 6 }

        statusSize =
            if isMobile then
                10

            else
                12

        dotSize =
            if isMobile then
                6

            else
                8
    in
    Element.row
        [ Element.spacing 6
        , Element.paddingXY pillPadding.x pillPadding.y
        , Border.rounded 9999
        , Border.width 1
        , Border.color
            (if isHealthy then
                colors.successSubtle

             else
                colors.errorSubtle
            )
        , Background.color
            (if isHealthy then
                colors.successSubtle

             else
                colors.errorSubtle
            )
        ]
        [ Element.el
            [ Element.width (px dotSize)
            , Element.height (px dotSize)
            , Border.rounded (dotSize // 2)
            , Background.color
                (if isHealthy then
                    colors.success

                 else
                    colors.error
                )
            ]
            Element.none
        , Element.el
            [ Font.size statusSize
            , Font.color
                (if isHealthy then
                    colors.success

                 else
                    colors.error
                )
            , Font.medium
            ]
            (Element.text status)
        ]
