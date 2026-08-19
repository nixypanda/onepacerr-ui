module Store exposing
    ( Model
    , Msg(..)
    , Loadable(..)
    , UiState
    , init
    , update
    , subscriptions
    )

import Api.Client exposing (ApiError)
import Api.Endpoints
import Data.Health exposing (Health)
import Data.Metadata exposing (Metadata)
import Data.Pipeline exposing (PipelineConfig, PipelineReport)
import Dict
import Time


type Loadable error value
    = NotAsked
    | Loading
    | Failure error
    | Success value


type alias UiState =
    { arcStates : Dict.Dict Int Bool
    , showConfig : Bool
    , windowWidth : Int
    }


type alias Model =
    { health : Loadable ApiError Health
    , metadata : Loadable ApiError Metadata
    , pipelineConfig : Loadable ApiError PipelineConfig
    , pipelineReport : Loadable ApiError PipelineReport
    , lastPoll : Maybe Int
    , now : Int
    , ui : UiState
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            { health = NotAsked
            , metadata = NotAsked
            , pipelineConfig = NotAsked
            , pipelineReport = NotAsked
            , lastPoll = Nothing
            , now = 0
            , ui =
                { arcStates = Dict.empty
                , showConfig = False
                , windowWidth = 1024
                }
            }
    in
    ( model, pollAll model )


type Msg
    = Tick Int
    | GotHealth (Result ApiError Health)
    | GotMetadata (Result ApiError Metadata)
    | GotPipelineConfig (Result ApiError PipelineConfig)
    | GotPipelineReport (Result ApiError PipelineReport)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick now ->
            let
                newModel = { model | now = now }
            in
            if shouldPoll model then
                ( newModel
                , pollAll newModel
                )
            else
                ( newModel, Cmd.none )

        GotHealth result ->
            ( { model | health = toLoadable result, lastPoll = Just model.now }, Cmd.none )

        GotMetadata result ->
            ( { model | metadata = toLoadable result }, Cmd.none )

        GotPipelineConfig result ->
            ( { model | pipelineConfig = toLoadable result }, Cmd.none )

        GotPipelineReport result ->
            ( { model | pipelineReport = toLoadable result }, Cmd.none )


toLoadable : Result error value -> Loadable error value
toLoadable result =
    case result of
        Ok value ->
            Success value

        Err error ->
            Failure error


shouldPoll : Model -> Bool
shouldPoll model =
    case model.lastPoll of
        Nothing ->
            True

        Just last ->
            model.now - last >= 30000


pollAll : Model -> Cmd Msg
pollAll model =
    let
        baseUrl = "/api"
    in
    Cmd.batch
        [ Api.Endpoints.healthRequest baseUrl |> Cmd.map GotHealth
        , Api.Endpoints.metadataRequest baseUrl |> Cmd.map GotMetadata
        , Api.Endpoints.pipelineConfigRequest baseUrl |> Cmd.map GotPipelineConfig
        , Api.Endpoints.pipelineReportRequest baseUrl |> Cmd.map GotPipelineReport
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every (30 * 1000) (\posix -> Tick (Time.posixToMillis posix))