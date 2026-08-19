module Api.Endpoints exposing
    ( healthRequest
    , metadataRequest
    , pipelineConfigRequest
    , pipelineReportRequest
    )

import Api.Client exposing (ApiError, get)
import Data.Health exposing (Health)
import Data.Metadata exposing (Metadata)
import Data.Pipeline exposing (PipelineConfig, PipelineReport)
import Json.Decode as Decode
import Lib.Json


healthRequest : String -> Cmd (Result ApiError Health)
healthRequest baseUrl =
    get (baseUrl ++ "/healthz") Lib.Json.healthDecoder


metadataRequest : String -> Cmd (Result ApiError Metadata)
metadataRequest baseUrl =
    get (baseUrl ++ "/status/metadata") Lib.Json.metadataDecoder


pipelineConfigRequest : String -> Cmd (Result ApiError PipelineConfig)
pipelineConfigRequest baseUrl =
    get (baseUrl ++ "/status/pipeline") Lib.Json.pipelineConfigDecoder


pipelineReportRequest : String -> Cmd (Result ApiError PipelineReport)
pipelineReportRequest baseUrl =
    get (baseUrl ++ "/status/pipeline/report") Lib.Json.pipelineReportDecoder