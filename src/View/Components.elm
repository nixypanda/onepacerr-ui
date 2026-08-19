module View.Components exposing
    ( archivedFileBadge
    , arcSection
    , card
    , configToggle
    , configToggleSection
    , emptyState
    , errorBanner
    , fileBadge
    , loadingSpinner
    , pipelineStatusBadge
    , arcStatusBadge
    , progressBar
    , statCard
    )

import Data.Pipeline exposing (ArcStatus(..), ArchivedFile, Episode, FileInfo, PipelineConfig, PipelineStatus(..))
import Element exposing (Element, px)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Lib.Date
import Ui.Theme exposing (colors)


statCard : String -> String -> String -> Element msg
statCard label value description =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 4
        , Element.paddingXY 0 4
        ]
        [ Element.el
            [ Font.size 12
            , Font.color colors.textMuted
            , Font.medium
            ]
            (Element.text label)
        , Element.el
            [ Font.size 28
            , Font.bold
            , Font.color colors.textPrimary
            ]
            (Element.text value)
        , Element.el
            [ Font.size 12
            , Font.color colors.textMuted
            ]
            (Element.text description)
        ]


card : List (Element.Attribute msg) -> List (Element msg) -> Element msg
card attrs children =
    Ui.Theme.card attrs children


pipelineStatusBadge : PipelineStatus -> Element msg
pipelineStatusBadge status =
    case status of
        Running ->
            Ui.Theme.badgeRunning [] [ Element.text "Running" ]

        Done ->
            Ui.Theme.badgeSuccess [] [ Element.text "Done" ]

        Errored ->
            Ui.Theme.badgeError [] [ Element.text "Errored" ]

        Ready ->
            Ui.Theme.badgeWarning [] [ Element.text "Ready" ]

        Pre ->
            Ui.Theme.badgeInfo [] [ Element.text "Pre" ]

        UnknownPipelineStatus raw ->
            Ui.Theme.badgeInfo [] [ Element.text raw ]


arcStatusBadge : ArcStatus -> Element msg
arcStatusBadge status =
    case status of
        Complete ->
            Ui.Theme.badgeSuccess [] [ Element.text "Complete" ]

        InProgress ->
            Ui.Theme.badgeRunning [] [ Element.text "In Progress" ]

        Planned ->
            Ui.Theme.badgeInfo [] [ Element.text "Planned" ]

        UnknownArcStatus raw ->
            Ui.Theme.badgeInfo [] [ Element.text raw ]


configToggleSection : Bool -> msg -> (String -> msg) -> Int -> PipelineConfig -> Element msg
configToggleSection showConfig toggleConfigMsg copyMsg windowWidth config =
    let
        isMobile = windowWidth < 640
    in
    Element.column
        [ Element.width Element.fill
        , Element.spacing 0
        ]
        [ Input.button
            [ Element.width Element.fill
            , Element.paddingXY 0 4
            ]
            { onPress = Just toggleConfigMsg
            , label =
                Element.row
                    [ Element.spacing 8
                    , Element.width Element.fill
                    , Element.centerY
                    ]
                    [ Ui.Theme.sectionHeader "Pipeline Configuration"
                    , Element.el [ Element.width Element.fill ] Element.none
                    , Element.el
                        [ Font.size 12
                        , Font.color colors.textMuted
                        ]
                        (Element.text
                            (if showConfig then
                                "Hide"

                             else
                                "Show"
                            )
                        )
                    , Element.el
                        [ Font.size 14
                        , Font.color colors.textMuted
                        ]
                        (Element.text
                            (if showConfig then
                                "\u{25B2}"

                             else
                                "\u{25BC}"
                            )
                        )
                    ]
            }
        , if showConfig then
            Element.column
                [ Element.spacing 4
                , Element.width Element.fill
                , Element.paddingXY 0 8
                ]
                [ configToggle windowWidth "Include Specials" config.includeSpecials "Process special episodes (arc 0)"
                , configToggle windowWidth "Prefer Extended" config.preferExtended "Prioritize extended cuts over standard"
                , configToggle windowWidth "Prefer Alternate" config.preferAlternate "Prefer G-8 cut at end of Skypiea"
                , configToggle windowWidth "Skip Verify Present" config.skipVerifyPresentFiles "Hash files present in library to verify latest version"
                , configToggle windowWidth "Skip Verify Not Extended" config.skipVerifyNotForExtended "Only verify non-extended episodes"
                , configToggle windowWidth "Skip Organize Present" config.skipOrganizePresentFiles "Ensure existing files are in correct folders"
                , configToggle windowWidth "Skip Update Metadata" config.skipUpdateMetadataPresentFiles "Update metadata for files already in library"
                , configToggle windowWidth "Skip Downloads" config.skipDownloads "Skip downloading, only organize existing"
                , configToggle windowWidth "Skip Downloads Imports" config.skipDownloadsImports "Skip importing downloaded files"
                , configToggle windowWidth "Force Redownload" config.forceRedownload "Redownload even if file exists"
                , configToggle windowWidth "Skip Posters" config.skipPosters "Skip updating poster artwork"
                , retryIntervalRow windowWidth config.retryInterval
                ]
                |> elWithPadding

          else
            Element.none
        ]


elWithPadding : Element msg -> Element msg
elWithPadding el =
    Element.el [ Element.width Element.fill ] el


configToggle : Int -> String -> Bool -> String -> Element msg
configToggle windowWidth label value description =
    let
        isMobile = windowWidth < 640
    in
    if isMobile then
        Element.column
            [ Element.spacing 8
            , Element.width Element.fill
            , Element.paddingXY 0 8
            ]
            [ Element.column
                [ Element.spacing 2
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Font.size 14
                    , Font.color colors.textPrimary
                    ]
                    (Element.text label)
                , Element.el
                    [ Font.size 12
                    , Font.color colors.textMuted
                    , Element.width Element.fill
                    ]
                    (Element.paragraph [] [ Element.text description ])
                ]
            , Ui.Theme.toggleTrack value
            ]

    else
        Element.row
            [ Element.spacing 12
            , Element.width Element.fill
            , Element.paddingXY 0 8
            ]
            [ Element.column
                [ Element.spacing 2
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Font.size 14
                    , Font.color colors.textPrimary
                    ]
                    (Element.text label)
                , Element.el
                    [ Font.size 12
                    , Font.color colors.textMuted
                    , Element.width Element.fill
                    ]
                    (Element.paragraph [] [ Element.text description ])
                ]
            , Ui.Theme.toggleTrack value
            ]


retryIntervalRow : Int -> Int -> Element msg
retryIntervalRow windowWidth interval =
    let
        isMobile = windowWidth < 640
    in
    if isMobile then
        Element.column
            [ Element.spacing 8
            , Element.width Element.fill
            , Element.paddingXY 0 8
            ]
            [ Element.column
                [ Element.spacing 2
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Font.size 14
                    , Font.color colors.textPrimary
                    ]
                    (Element.text "Retry Interval")
                , Element.el
                    [ Font.size 12
                    , Font.color colors.textMuted
                    ]
                    (Element.text "Seconds between retries")
                ]
            , Element.el
                [ Font.size 14
                , Font.color colors.textSecondary
                ]
                (Element.text (String.fromInt interval ++ "s"))
            ]

    else
        Element.row
            [ Element.spacing 12
            , Element.width Element.fill
            , Element.paddingXY 0 8
            ]
            [ Element.column
                [ Element.spacing 2
                , Element.width Element.fill
                ]
                [ Element.el
                    [ Font.size 14
                    , Font.color colors.textPrimary
                    ]
                    (Element.text "Retry Interval")
                , Element.el
                    [ Font.size 12
                    , Font.color colors.textMuted
                    ]
                    (Element.text "Seconds between retries")
                ]
            , Element.el
                [ Font.size 14
                , Font.color colors.textSecondary
                ]
                (Element.text (String.fromInt interval ++ "s"))
            ]


clickable : List (Element.Attribute msg) -> Element msg -> msg -> Element msg
clickable attrs children msg =
    Input.button
        ([ Element.width Element.fill ] ++ attrs)
        { onPress = Just msg
        , label = children
        }


arcSection :
    (String -> msg)
    -> Int
    -> { arc : Int
       , saga : String
       , title : String
       , description : String
       , status : ArcStatus
       , episodes : List Episode
       }
    -> Bool
    -> (Int -> msg)
    -> Element msg
arcSection copyMsg windowWidth arc isExpanded onToggle =
    let
        isMobile = windowWidth < 640
    in
    Element.column
        [ Element.width Element.fill
        , Element.spacing 0
        ]
        [ clickable
            [ Element.width Element.fill
            , Element.paddingXY 16 14
            , Background.color
                (if isExpanded then
                    colors.surfaceElevated

                 else
                    colors.surface
                )
            , Border.rounded 8
            , Border.width 1
            , Border.color
                (if isExpanded then
                    colors.border

                 else
                    colors.borderSubtle
                )
            ]
            (if isMobile then
                Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    ]
                    [ Element.row
                        [ Element.spacing 8
                        , Element.width Element.fill
                        , Element.centerY
                        ]
                        [ Element.el
                            [ Font.size 13
                            , Font.color colors.textMuted
                            , Element.width (px 24)
                            ]
                            (Element.text (String.fromInt arc.arc))
                        , Element.el
                            [ Font.size 14
                            , Font.semiBold
                            , Font.color colors.textPrimary
                            , Element.width Element.fill
                            ]
                            (Element.paragraph [] [ Element.text arc.title ])
                        , Element.el
                            [ Font.size 16
                            , Font.color colors.textMuted
                            , Element.width (px 20)
                            , Element.centerX
                            ]
                            (Element.text
                                (if isExpanded then
                                    "\u{2212}"

                                 else
                                    "+"
                                )
                            )
                        ]
                    , Element.row
                        [ Element.spacing 8
                        , Element.width Element.fill
                        , Element.paddingXY 32 0
                        ]
                        [ Element.el
                            [ Font.size 12
                            , Font.color colors.textMuted
                            , Element.width Element.fill
                            ]
                            (Element.paragraph [] [ Element.text arc.saga ])
                        , arcStatusBadge arc.status
                        , Element.el
                            [ Font.size 12
                            , Font.color colors.textMuted
                            ]
                            (Element.text (String.fromInt (List.length arc.episodes) ++ " eps"))
                        ]
                    ]

             else
                Element.row
                    [ Element.spacing 12
                    , Element.width Element.fill
                    , Element.centerY
                    ]
                    [ Element.el
                        [ Font.size 13
                        , Font.color colors.textMuted
                        , Element.width (px 24)
                        ]
                        (Element.text (String.fromInt arc.arc))
                    , Element.column
                        [ Element.spacing 2
                        , Element.width Element.fill
                        ]
                        [ Element.el
                            [ Font.size 14
                            , Font.semiBold
                            , Font.color colors.textPrimary
                            , Element.width Element.fill
                            ]
                            (Element.paragraph [] [ Element.text arc.title ])
                        , Element.el
                            [ Font.size 12
                            , Font.color colors.textMuted
                            , Element.width Element.fill
                            ]
                            (Element.paragraph [] [ Element.text arc.saga ])
                        ]
                    , arcStatusBadge arc.status
                    , Element.el
                        [ Font.size 12
                        , Font.color colors.textMuted
                        ]
                        (Element.text (String.fromInt (List.length arc.episodes) ++ " eps"))
                    , Element.el
                        [ Font.size 16
                        , Font.color colors.textMuted
                        , Element.width (px 20)
                        , Element.centerX
                        ]
                        (Element.text
                            (if isExpanded then
                                "\u{2212}"

                             else
                                "+"
                            )
                        )
                    ]
            )
            (onToggle arc.arc)
        , if isExpanded then
            Element.column
                [ Element.spacing 8
                , Element.paddingXY 16 12
                , Element.width Element.fill
                ]
                (List.map (episodeRow copyMsg windowWidth) arc.episodes)

          else
            Element.none
        ]


episodeRow : (String -> msg) -> Int -> Episode -> Element msg
episodeRow copyMsg windowWidth ep =
    let
        isMobile = windowWidth < 640
    in
    Element.el
        [ Element.width Element.fill
        , Element.paddingXY 16 12
        , Background.color colors.surface
        , Border.rounded 6
        , Border.width 1
        , Border.color colors.borderSubtle
        ]
        (Element.column
            [ Element.spacing 8
            , Element.width Element.fill
            ]
            [ if isMobile then
                Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    ]
                    [ Element.column
                        [ Element.spacing 2
                        , Element.width Element.fill
                        ]
                        [ Element.row
                            [ Element.spacing 8
                            , Element.centerY
                            , Element.width Element.fill
                            ]
                            [ Element.el
                                [ Font.size 13
                                , Font.semiBold
                                , Font.color colors.textPrimary
                                ]
                                (Element.text ("Ep " ++ String.fromInt ep.episode))
                            , Element.el
                                [ Font.size 13
                                , Font.color colors.textSecondary
                                , Element.width Element.fill
                                ]
                                (Element.paragraph [] [ Element.text ep.title ])
                            ]
                        , case ep.description of
                            Just desc ->
                                Element.el
                                    [ Font.size 12
                                    , Font.color colors.textMuted
                                    , Element.width Element.fill
                                    ]
                                    (Element.paragraph [] [ Element.text desc ])

                            Nothing ->
                                Element.none
                        ]
                    , fileBadge copyMsg ep.files.standard
                    ]

              else
                Element.row
                    [ Element.spacing 12
                    , Element.width Element.fill
                    , Element.centerY
                    ]
                    [ Element.column
                        [ Element.spacing 2
                        , Element.width Element.fill
                        ]
                        [ Element.row
                            [ Element.spacing 8
                            , Element.centerY
                            , Element.width Element.fill
                            ]
                            [ Element.el
                                [ Font.size 13
                                , Font.semiBold
                                , Font.color colors.textPrimary
                                ]
                                (Element.text ("Ep " ++ String.fromInt ep.episode))
                            , Element.el
                                [ Font.size 13
                                , Font.color colors.textSecondary
                                , Element.width Element.fill
                                ]
                                (Element.paragraph [] [ Element.text ep.title ])
                            ]
                        , case ep.description of
                            Just desc ->
                                Element.el
                                    [ Font.size 12
                                    , Font.color colors.textMuted
                                    , Element.width Element.fill
                                    ]
                                    (Element.paragraph [] [ Element.text desc ])

                            Nothing ->
                                Element.none
                        ]
                    , fileBadge copyMsg ep.files.standard
                    ]
            , if List.isEmpty ep.files.archived then
                Element.none

              else
                Element.row
                    [ Element.spacing 8
                    , Element.width Element.fill
                    ]
                    (List.map (archivedFileBadge copyMsg) ep.files.archived)
            ]
        )


fileBadge : (String -> msg) -> FileInfo -> Element msg
fileBadge copyMsg file =
    Element.row
        [ Element.spacing 8
        , Element.paddingXY 10 6
        , Background.color colors.surfaceElevated
        , Border.rounded 6
        , Border.width 1
        , Border.color colors.borderSubtle
        , Element.centerY
        ]
        [ Element.el
            [ Font.size 12
            , Font.color colors.textSecondary
            ]
            (Element.text file.variant)
        , Element.el
            [ Font.size 12
            , Font.color colors.textMuted
            ]
            (Element.text (Lib.Date.formatDuration file.duration))
        , copyButton copyMsg
        ]


archivedFileBadge : (String -> msg) -> ArchivedFile -> Element msg
archivedFileBadge copyMsg file =
    Element.row
        [ Element.spacing 6
        , Element.paddingXY 8 4
        , Background.color colors.surface
        , Border.rounded 6
        , Border.width 1
        , Border.color colors.borderSubtle
        , Element.centerY
        ]
        [ Element.el
            [ Font.size 11
            , Font.color colors.textMuted
            ]
            (Element.text ("archived: " ++ file.variant))
        , copyButton copyMsg
        ]


copyButton : (String -> msg) -> Element msg
copyButton copyMsg =
    Input.button
        [ Element.width (px 24)
        , Element.height (px 24)
        , Background.color colors.surfaceHover
        , Border.rounded 4
        , Element.centerY
        ]
        { onPress = Just (copyMsg "")
        , label =
            Element.el
                [ Font.size 10
                , Font.color colors.textMuted
                , Element.centerX
                , Element.centerY
                ]
                (Element.text "Copy")
        }


progressBar : Int -> Int -> Element msg
progressBar current total =
    let
        percentage =
            if total > 0 then
                toFloat current / toFloat total * 100

            else
                0

        barColor =
            if percentage >= 100 then
                colors.success

            else
                colors.accent
    in
    Element.column
        [ Element.spacing 8
        , Element.width Element.fill
        ]
        [ Element.row
            [ Element.spacing 8
            , Element.width Element.fill
            , Element.centerY
            ]
            [ Element.el
                [ Font.size 14
                , Font.color colors.textSecondary
                ]
                (Element.text "Progress")
            , Element.el [ Element.width Element.fill ] Element.none
            , Element.el
                [ Font.size 14
                , Font.semiBold
                , Font.color colors.textPrimary
                ]
                (Element.text
                    (String.fromInt current
                        ++ " / "
                        ++ String.fromInt total
                        ++ " ("
                        ++ String.fromInt (round percentage)
                        ++ "%)"
                    )
                )
            ]
        , Element.el
            [ Element.width Element.fill
            , Element.height (px 8)
            , Background.color colors.surfaceElevated
            , Border.rounded 4
            ]
            (Element.el
                [ Element.width
                    (if percentage >= 100 then
                        Element.fill

                     else
                        Element.fillPortion (round percentage)
                    )
                , Element.height (px 8)
                , Background.color barColor
                , Border.rounded 4
                ]
                Element.none
            )
        ]


errorBanner : String -> Element msg
errorBanner message =
    Element.row
        [ Element.spacing 10
        , Element.width Element.fill
        , Element.paddingXY 16 14
        , Background.color colors.errorSubtle
        , Border.rounded 8
        , Border.width 1
        , Border.color colors.error
        ]
        [ Element.el
            [ Font.size 14
            , Font.color colors.error
            ]
            (Element.text "\u{26A0}")
        , Element.el
            [ Font.size 13
            , Font.color colors.error
            , Element.width Element.fill
            ]
            (Element.paragraph [] [ Element.text message ])
        ]


loadingSpinner : Element msg
loadingSpinner =
    Element.column
        [ Element.spacing 16
        , Element.padding 48
        , Element.width Element.fill
        , Element.centerX
        ]
        [ Element.el
            [ Element.width (px 32)
            , Element.height (px 32)
            , Border.width 2
            , Border.color colors.surfaceElevated
            , Border.rounded 16
            , Element.centerX
            ]
            Element.none
        , Element.el
            [ Font.size 13
            , Font.color colors.textMuted
            , Element.centerX
            ]
            (Element.text "Loading...")
        ]


emptyState : String -> Element msg
emptyState message =
    Element.column
        [ Element.spacing 8
        , Element.width Element.fill
        , Element.padding 48
        , Element.centerX
        ]
        [ Element.el
            [ Font.size 24
            , Element.centerX
            ]
            (Element.text "\u{25CB}")
        , Element.el
            [ Font.size 13
            , Font.color colors.textMuted
            , Element.centerX
            ]
            (Element.text message)
        ]
