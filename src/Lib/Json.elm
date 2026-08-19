module Lib.Json exposing
    ( apiErrorDecoder
    , healthDecoder
    , metadataDecoder
    , pipelineConfigDecoder
    , pipelineReportDecoder
    )

import Data.Health exposing (Health, Posix)
import Data.Metadata exposing (Metadata, MetadataConfig)
import Data.Pipeline
    exposing
        ( ArcStatus(..)
        , ArchivedFile
        , Episode
        , EpisodeFiles
        , FileInfo
        , MonitoredArc
        , PipelineConfig
        , PipelineReport
        , PipelineStatus(..)
        )
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline


healthDecoder : Decoder Health
healthDecoder =
    Decode.map3 Health
        (Decode.field "name" Decode.string)
        (Decode.field "httpCode" Decode.int)
        (Decode.field "message" Decode.string)


metadataConfigDecoder : Decoder MetadataConfig
metadataConfigDecoder =
    Decode.map4 MetadataConfig
        (Decode.field "METADATA_URL" Decode.string)
        (Decode.field "METADATA_LANGUAGE" Decode.string)
        (Decode.field "METADATA_POSTER_SET" Decode.string)
        (Decode.field "METADATA_CHECK_INTERVAL" Decode.int)


metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.map3 Metadata
        (Decode.field "url" Decode.string)
        (Decode.field "configs" metadataConfigDecoder)
        (Decode.field "downloaded" Decode.bool)


pipelineStatusDecoder : Decoder PipelineStatus
pipelineStatusDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "PRE" ->
                        Decode.succeed Pre

                    "READY" ->
                        Decode.succeed Ready

                    "RUNNING" ->
                        Decode.succeed Running

                    "DONE" ->
                        Decode.succeed Done

                    "ERRORED" ->
                        Decode.succeed Errored

                    _ ->
                        Decode.succeed (UnknownPipelineStatus s)
            )


arcStatusDecoder : Decoder ArcStatus
arcStatusDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "complete" ->
                        Decode.succeed Complete

                    "wip" ->
                        Decode.succeed InProgress

                    "tbr" ->
                        Decode.succeed Planned

                    _ ->
                        Decode.succeed (UnknownArcStatus s)
            )


pipelineConfigDecoder : Decoder PipelineConfig
pipelineConfigDecoder =
    Decode.field "config" pipelineConfigFieldsDecoder


pipelineConfigFieldsDecoder : Decoder PipelineConfig
pipelineConfigFieldsDecoder =
    Decode.succeed PipelineConfig
        |> Pipeline.required "PIPELINE_SKIP_VERIFY_PRESENT_FILES" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_VERIFY_NOT_FOR_EXTENDED" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_ORGANIZE_PRESENT_FILES" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_UPDATE_METADATA_PRESENT_FILES" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_DOWNLOADS" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_DOWNLOADS_IMPORTS" Decode.bool
        |> Pipeline.required "PIPELINE_FORCE_REDOWNLOAD" Decode.bool
        |> Pipeline.required "PIPELINE_SKIP_POSTERS" Decode.bool
        |> Pipeline.required "PIPELINE_INCLUDE_SPECIALS" Decode.bool
        |> Pipeline.required "PIPELINE_PREFER_EXTENDED" Decode.bool
        |> Pipeline.required "PIPELINE_PREFER_ALTERNATE" Decode.bool
        |> Pipeline.required "PIPELINE_RETRY_INTERVAL" Decode.int


archivedFileDecoder : Decoder ArchivedFile
archivedFileDecoder =
    Decode.map6 ArchivedFile
        (Decode.field "CRC32" Decode.string)
        (Decode.field "hash" Decode.string)
        (Decode.field "magnetURI" Decode.string)
        (Decode.field "variant" Decode.string)
        (Decode.field "outdated" (Decode.maybe Decode.bool)
            |> Decode.map (Maybe.withDefault False)
        )
        (Decode.maybe (Decode.field "partOfBundle" Decode.bool))


fileInfoDecoder : Decoder FileInfo
fileInfoDecoder =
    Decode.map7 FileInfo
        (Decode.field "CRC32" Decode.string)
        (Decode.field "hash" Decode.string)
        (Decode.field "magnetURI" Decode.string)
        (Decode.maybe (Decode.field "duration" Decode.int))
        (Decode.field "variant" Decode.string)
        (Decode.maybe (Decode.field "partOfBundle" Decode.bool))
        (Decode.maybe (Decode.field "CRC32_inFileName" Decode.string))


episodeFilesDecoder : Decoder EpisodeFiles
episodeFilesDecoder =
    Decode.map3 EpisodeFiles
        (Decode.field "standard" fileInfoDecoder)
        (Decode.maybe (Decode.field "extended" fileInfoDecoder))
        (Decode.field "archived" (Decode.list archivedFileDecoder)
            |> Decode.maybe
            |> Decode.map (Maybe.withDefault [])
        )


posixDecoder : Decoder Posix
posixDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case parseIso8601 s of
                    Ok posix ->
                        Decode.succeed posix

                    Err _ ->
                        case Decode.decodeString Decode.int s of
                            Ok posix ->
                                Decode.succeed posix

                            Err _ ->
                                case Decode.decodeString Decode.float s of
                                    Ok posix ->
                                        Decode.succeed (round posix)

                                    Err _ ->
                                        Decode.fail ("Invalid Posix timestamp: " ++ s)
            )


parseIso8601 : String -> Result String Int
parseIso8601 s =
    case String.split "T" s of
        [ datePart, timePart ] ->
            case parseDatePart datePart of
                Err err ->
                    Err err

                Ok daysBefore ->
                    case parseTimePart timePart of
                        Err err ->
                            Err err

                        Ok timeMillis ->
                            Ok (daysBefore * 86400 * 1000 + timeMillis)

        _ ->
            Err ("Invalid ISO 8601 format: " ++ s)


parseDatePart : String -> Result String Int
parseDatePart datePart =
    let
        fields =
            String.split "-" datePart
    in
    case fields of
        [ yStr, mStr, dStr ] ->
            case ( String.toInt yStr, String.toInt mStr, String.toInt dStr ) of
                ( Just year, Just month, Just day ) ->
                    let
                        y =
                            year - 1

                        daysBeforeYear =
                            365 * y + y // 4 - y // 100 + y // 400

                        daysBeforeMonth =
                            if month <= 2 then
                                0

                            else
                                let
                                    isLeap =
                                        modBy 4 year == 0 && (modBy 100 year /= 0 || modBy 400 year == 0)

                                    leapAdjust =
                                        if isLeap then
                                            1

                                        else
                                            0

                                    regularDays =
                                        (month - 1) * 30 + (month - 1) // 2
                                            - (if month > 7 then
                                                2

                                               else if month > 2 then
                                                0

                                               else
                                                0
                                              )
                                in
                                regularDays + leapAdjust
                    in
                    Ok (daysBeforeYear + daysBeforeMonth + day - 719468)

                _ ->
                    Err ("Invalid date fields in: " ++ datePart)

        _ ->
            Err ("Invalid date format: " ++ datePart)


parseTimePart : String -> Result String Int
parseTimePart timePart =
    let
        cleanTime =
            String.replace "Z" "" timePart

        fields =
            String.split ":" cleanTime
    in
    case fields of
        [ hStr, mStr, secStr ] ->
            let
                hourResult =
                    String.toInt hStr

                minuteResult =
                    String.toInt mStr

                secInt =
                    String.split "." secStr |> List.head |> Maybe.andThen String.toInt
            in
            case ( hourResult, minuteResult, secInt ) of
                ( Just hour, Just minute, Just sec ) ->
                    Ok ((hour * 3600 + minute * 60 + sec) * 1000)

                _ ->
                    Err ("Invalid time fields in: " ++ timePart)

        _ ->
            Err ("Invalid time format: " ++ timePart)


episodeDecoder : Decoder Episode
episodeDecoder =
    Decode.map8 Episode
        (Decode.field "arc" Decode.int)
        (Decode.field "episode" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.maybe (Decode.field "description" Decode.string))
        (Decode.maybe (Decode.field "released" posixDecoder))
        (Decode.maybe (Decode.field "mangaChapters" Decode.string))
        (Decode.maybe (Decode.field "animeEpisodes" Decode.string))
        (Decode.field "files" episodeFilesDecoder)


monitoredArcDecoder : Decoder MonitoredArc
monitoredArcDecoder =
    Decode.map6 MonitoredArc
        (Decode.field "arc" Decode.int)
        (Decode.field "saga" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "description" Decode.string)
        (Decode.field "status" arcStatusDecoder)
        (Decode.field "episodes" (Decode.list episodeDecoder))


pipelineReportDecoder : Decoder PipelineReport
pipelineReportDecoder =
    Decode.map8 PipelineReport
        (Decode.field "created" posixDecoder)
        (Decode.maybe (Decode.field "started" posixDecoder))
        (Decode.maybe (Decode.field "ended" posixDecoder))
        (Decode.field "monitored" (Decode.list monitoredArcDecoder))
        (Decode.field "processedEpisodes" Decode.int)
        (Decode.field "monitoredEpisodes" Decode.int)
        (Decode.field "status" pipelineStatusDecoder)
        (Decode.maybe (Decode.field "error" Decode.string))


apiErrorDecoder : Decoder String
apiErrorDecoder =
    Decode.string
