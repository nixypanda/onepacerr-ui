module View.Dashboard exposing
    ( view
    )

import Data.Health exposing (Health)
import Data.Metadata exposing (Metadata)
import Data.Pipeline exposing
        ( PipelineConfig
        , PipelineReport
        , PipelineStatus(..)
        , MonitoredArc
        )
import Dict
import Element exposing (Element, px)
import Element.Font as Font
import Lib.Date
import Store exposing (Model, Loadable(..))
import Ui.Theme exposing (colors)
import View.Components as Components
import View.Layout as Layout


type alias ArcState =
    Dict.Dict Int Bool


view : (String -> msg) -> msg -> Model -> ArcState -> (Int -> msg) -> Element msg
view copyMsg toggleConfigMsg model arcStates onToggleArc =
    let
        healthStatus =
            healthStatusView model.health

        progress =
            progressView model.pipelineReport

        config =
            configView model.ui.showConfig toggleConfigMsg copyMsg model.ui.windowWidth model.pipelineConfig

        arcs =
            arcsView copyMsg model.ui.windowWidth model.pipelineReport arcStates onToggleArc
    in
    Layout.view
        { title = "OnePacerr"
        , subtitle = "One Pace Episode Manager"
        , healthStatus = healthStatus
        , isHealthy = isHealthy model.health
        , windowWidth = model.ui.windowWidth
        , children =
            [ statsRow model.ui.windowWidth model.pipelineReport
            , progress
            , config
            , arcs
            ]
        }


healthStatusView : Loadable error Health -> String
healthStatusView loadable =
    case loadable of
        Success health ->
            health.name ++ " " ++ String.fromInt health.httpCode

        Failure _ ->
            "API Error"

        Loading ->
            "Checking..."

        NotAsked ->
            "Unknown"


isHealthy : Loadable error Health -> Bool
isHealthy loadable =
    case loadable of
        Success health ->
            health.httpCode == 200

        _ ->
            False


statsRow : Int -> Loadable error PipelineReport -> Element msg
statsRow windowWidth loadable =
    let
        isMobile = windowWidth < 640

        statCards =
            case loadable of
                Success report ->
                    [ Components.statCard "Status" (statusLabel report.status) (statusDescription report.status)
                    , Components.statCard "Monitored" (String.fromInt report.monitoredEpisodes) "episodes tracked"
                    , Components.statCard "Processed" (String.fromInt report.processedEpisodes) "downloaded & organized"
                    , Components.statCard "Arcs" (String.fromInt (List.length report.monitored)) "sagas / seasons"
                    ]

                _ ->
                    [ Components.statCard "Status" "--" "Loading..."
                    , Components.statCard "Monitored" "--" "Loading..."
                    , Components.statCard "Processed" "--" "Loading..."
                    , Components.statCard "Arcs" "--" "Loading..."
                    ]
    in
    Components.card
        [ Element.width Element.fill ]
        [ if isMobile then
            Element.wrappedRow
                [ Element.spacing 16
                , Element.width Element.fill
                ]
                    (List.map
                        (\card ->
                            Element.el
                                [ Element.width (Element.minimum 140 (Element.fillPortion 1))
                                ]
                                card
                    )
                    statCards
                )

          else
            Element.row
                [ Element.spacing 32
                , Element.width Element.fill
                ]
                statCards
        ]


statusLabel : PipelineStatus -> String
statusLabel status =
    case status of
        Running ->
            "Running"

        Done ->
            "Done"

        Errored ->
            "Errored"

        Ready ->
            "Ready"

        Pre ->
            "Pre"

        UnknownPipelineStatus raw ->
            raw


statusDescription : PipelineStatus -> String
statusDescription status =
    case status of
        Running ->
            "Actively processing"

        Done ->
            "Last run completed"

        Errored ->
            "Pipeline failed"

        Ready ->
            "Ready to run"

        Pre ->
            "Initializing"

        UnknownPipelineStatus _ ->
            "Unknown status"


progressView : Loadable error PipelineReport -> Element msg
progressView loadable =
    case loadable of
        Success report ->
            Components.card
                [ Element.width Element.fill ]
                [ Components.progressBar report.processedEpisodes report.monitoredEpisodes ]

        _ ->
            Element.none


configView : Bool -> msg -> (String -> msg) -> Int -> Loadable error PipelineConfig -> Element msg
configView showConfig toggleConfigMsg copyMsg windowWidth loadable =
    case loadable of
        Success config ->
            Components.card
                [ Element.width Element.fill ]
                [ Components.configToggleSection showConfig toggleConfigMsg copyMsg windowWidth config ]

        _ ->
            Element.none


arcsView : (String -> msg) -> Int -> Loadable error PipelineReport -> ArcState -> (Int -> msg) -> Element msg
arcsView copyMsg windowWidth loadable arcStates onToggleArc =
    case loadable of
        Success report ->
            Components.card
                [ Element.width Element.fill ]
                [ Element.row
                    [ Element.spacing 12
                    , Element.width Element.fill
                    ]
                    [ Ui.Theme.sectionHeader "Arcs & Episodes"
                    , Element.el [ Element.width Element.fill ] Element.none
                    , Element.el
                        [ Font.size 12
                        , Font.color colors.textMuted
                        ]
                        (Element.text (String.fromInt (List.length report.monitored) ++ " arcs"))
                    ]
                , Element.column
                    [ Element.spacing 8
                    , Element.width Element.fill
                    ]
                    (List.indexedMap
                        (\i arc ->
                            let
                                isExpanded =
                                    Dict.get arc.arc arcStates |> Maybe.withDefault False
                            in
                            Components.arcSection copyMsg windowWidth arc isExpanded onToggleArc
                        )
                        report.monitored
                    )
                ]

        Loading ->
            Components.loadingSpinner

        Failure err ->
            Components.errorBanner "Failed to load arcs"

        NotAsked ->
            Components.emptyState "Arcs not loaded"
