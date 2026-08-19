port module Main exposing (main)

import Browser
import Browser.Events
import Dict
import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Store exposing (Model, Msg(..), init, update, subscriptions)
import Ui.Theme exposing (colors)
import View.Dashboard as Dashboard


type alias Flags =
    { apiBaseUrl : String
    , windowWidth : Int
    , windowHeight : Int
    }


main : Program Flags Model Msg
main =
    Browser.element
        { init = initWithFlags
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


initWithFlags : Flags -> ( Model, Cmd Msg )
initWithFlags flags =
    let
        ( model, cmd ) =
            init
    in
    ( { model | now = 0, ui = { arcStates = Dict.empty, showConfig = False, windowWidth = flags.windowWidth } }
    , Cmd.map StoreMsg cmd
    )


view : Model -> Html Msg
view model =
    Element.layout
        [ Background.color colors.bg
        , Font.color colors.textPrimary
        ]
        (Dashboard.view CopyToClipboard ToggleConfig model model.ui.arcStates ToggleArc)


type Msg
    = StoreMsg Store.Msg
    | ToggleArc Int
    | ToggleConfig
    | CopyToClipboard String
    | CopyResult Bool
    | WindowResize Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreMsg storeMsg ->
            let
                ( newModel, cmd ) =
                    Store.update storeMsg model
            in
            ( newModel, Cmd.map StoreMsg cmd )

        ToggleArc arc ->
            let
                oldUi =
                    model.ui

                newArcStates =
                    Dict.update arc
                        (\current ->
                            Just (not (Maybe.withDefault False current))
                        )
                        oldUi.arcStates
            in
            ( { model | ui = { oldUi | arcStates = newArcStates } }, Cmd.none )

        ToggleConfig ->
            let
                oldUi =
                    model.ui
            in
            ( { model | ui = { oldUi | showConfig = not oldUi.showConfig } }, Cmd.none )

        CopyToClipboard uri ->
            ( model, copyToClipboard uri )

        CopyResult success ->
            ( model, Cmd.none )

        WindowResize width _ ->
            let
                oldUi = model.ui
            in
            ( { model | ui = { oldUi | windowWidth = width } }, Cmd.none )


port copyToClipboard : String -> Cmd msg


port copyResult : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map StoreMsg (Store.subscriptions model)
        , copyResult CopyResult
        , Browser.Events.onResize WindowResize
        ]
