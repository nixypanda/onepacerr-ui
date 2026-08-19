module JsonDecodeTest exposing (suite)

import Data.Health exposing (Health, Posix)
import Data.Metadata exposing (Metadata, MetadataConfig)
import Data.Pipeline
    exposing
        ( ArcStatus(..)
        , MonitoredArc
        , PipelineConfig
        , PipelineReport
        , PipelineStatus(..)
        )
import Expect
import Json.Decode as Decode
import Lib.Json
    exposing
        ( healthDecoder
        , metadataDecoder
        , pipelineConfigDecoder
        , pipelineReportDecoder
        )
import Test exposing (..)


suite : Test
suite =
    describe "JSON Decoders against real API responses"
        [ healthDecoderTest
        , metadataDecoderTest
        , pipelineConfigDecoderTest
        , pipelineReportDecoderTest
        ]


healthDecoderTest : Test
healthDecoderTest =
    test "decodes healthz response" <|
        \_ ->
            let
                json =
                    """{"name":"OK","httpCode":200,"message":"Ok"}"""

                result =
                    Decode.decodeString healthDecoder json
            in
            case result of
                Ok health ->
                    Expect.all
                        [ \h -> Expect.equal "OK" h.name
                        , \h -> Expect.equal 200 h.httpCode
                        , \h -> Expect.equal "Ok" h.message
                        ]
                        health

                Err err ->
                    Expect.fail (Decode.errorToString err)


metadataDecoderTest : Test
metadataDecoderTest =
    test "decodes metadata response" <|
        \_ ->
            let
                json =
                    """{"url":"https://onepacerr.com/api/v1","configs":{"METADATA_URL":"https://onepacerr.com/api/v1","METADATA_LANGUAGE":"en","METADATA_POSTER_SET":"default","METADATA_CHECK_INTERVAL":3600},"downloaded":false}"""

                result =
                    Decode.decodeString metadataDecoder json
            in
            case result of
                Ok metadata ->
                    Expect.all
                        [ \m -> Expect.equal "https://onepacerr.com/api/v1" m.url
                        , \m -> Expect.equal "en" m.configs.metadataLanguage
                        , \m -> Expect.equal 3600 m.configs.metadataCheckInterval
                        , \m -> Expect.equal False m.downloaded
                        ]
                        metadata

                Err err ->
                    Expect.fail (Decode.errorToString err)


pipelineConfigDecoderTest : Test
pipelineConfigDecoderTest =
    test "decodes pipeline config from nested response" <|
        \_ ->
            let
                json =
                    """{"config":{"PIPELINE_SKIP_VERIFY_PRESENT_FILES":false,"PIPELINE_SKIP_VERIFY_NOT_FOR_EXTENDED":false,"PIPELINE_SKIP_ORGANIZE_PRESENT_FILES":false,"PIPELINE_SKIP_UPDATE_METADATA_PRESENT_FILES":false,"PIPELINE_SKIP_DOWNLOADS":false,"PIPELINE_SKIP_DOWNLOADS_IMPORTS":false,"PIPELINE_FORCE_REDOWNLOAD":false,"PIPELINE_SKIP_POSTERS":false,"PIPELINE_INCLUDE_SPECIALS":true,"PIPELINE_PREFER_EXTENDED":true,"PIPELINE_PREFER_ALTERNATE":true,"PIPELINE_RETRY_INTERVAL":10000},"monitored":{"seasons":37,"episodes":481}}"""

                result =
                    Decode.decodeString pipelineConfigDecoder json
            in
            case result of
                Ok config ->
                    Expect.all
                        [ \c -> Expect.equal False c.skipVerifyPresentFiles
                        , \c -> Expect.equal True c.includeSpecials
                        , \c -> Expect.equal True c.preferExtended
                        , \c -> Expect.equal 10000 c.retryInterval
                        ]
                        config

                Err err ->
                    Expect.fail (Decode.errorToString err)


pipelineReportDecoderTest : Test
pipelineReportDecoderTest =
    describe "pipelineReportDecoder"
        [ test "decodes pipeline report with ISO 8601 timestamps" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","started":"2026-08-18T17:54:48.208Z","ended":"2026-08-18T18:37:55.470Z","monitored":[],"processedEpisodes":481,"monitoredEpisodes":481,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        Expect.all
                            [ \r -> Expect.equal 481 r.processedEpisodes
                            , \r -> Expect.equal Done r.status
                            , \r -> Expect.greaterThan 0 r.created
                            ]
                            report

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes pipeline report with nested episodes" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":0,"saga":"Specials","title":"Specials","description":"Desc.","status":"complete","episodes":[{"arc":0,"episode":1,"title":"One Piece Fan Letter","description":"As the Straw Hat Pirates reunite.","files":{"standard":{"CRC32":"59510B34","hash":"80872a919a43b5d044caa3fd80933707344e4fab","magnetURI":"magnet:?xt=urn:btih:test","variant":"standard"},"archived":[{"CRC32":"9974A092","hash":"89913d954cec1c03a50667b81bc2b9508c4f2214","magnetURI":"magnet:?xt=urn:btih:test2","variant":"standard","outdated":true}]}}]}],"processedEpisodes":481,"monitoredEpisodes":481,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                case List.head arc.episodes of
                                    Just ep ->
                                        Expect.all
                                            [ \e -> Expect.equal "One Piece Fan Letter" e.title
                                            , \e -> Expect.equal "59510B34" e.files.standard.crc32
                                            , \e -> Expect.equal Nothing e.files.extended
                                            , \e -> Expect.equal 1 (List.length e.files.archived)
                                            ]
                                            ep

                                    Nothing ->
                                        Expect.fail "Expected at least one episode"

                            Nothing ->
                                Expect.fail "Expected at least one arc"

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes episode with no archived field" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":0,"saga":"Specials","title":"Specials","description":"Desc.","status":"complete","episodes":[{"arc":0,"episode":2,"title":"Wapol","description":"Desc.","files":{"standard":{"CRC32":"05BE81E6","hash":"91c2900b","magnetURI":"magnet:?xt=urn:btih:test","variant":"standard"}}}]}],"processedEpisodes":1,"monitoredEpisodes":1,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                case List.head arc.episodes of
                                    Just ep ->
                                        Expect.all
                                            [ \e -> Expect.equal [] e.files.archived
                                            , \e -> Expect.equal Nothing e.files.extended
                                            ]
                                            ep

                                    Nothing ->
                                        Expect.fail "Expected episode"

                            Nothing ->
                                Expect.fail "Expected arc"

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes episode with extended and no duration" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":0,"saga":"Specials","title":"Specials","description":"Desc.","status":"complete","episodes":[{"arc":0,"episode":3,"title":"Strong World","description":"Desc.","files":{"standard":{"CRC32":"76B2C869","hash":"a3b44935","magnetURI":"magnet:?xt=urn:btih:test","variant":"standard","partOfBundle":true}}}]}],"processedEpisodes":1,"monitoredEpisodes":1,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                case List.head arc.episodes of
                                    Just ep ->
                                        Expect.all
                                            [ \e -> Expect.equal Nothing e.files.standard.duration
                                            , \e -> Expect.equal (Just True) e.files.standard.partOfBundle
                                            , \e -> Expect.equal Nothing e.files.extended
                                            , \e -> Expect.equal [] e.files.archived
                                            ]
                                            ep

                                    Nothing ->
                                        Expect.fail "Expected episode"

                            Nothing ->
                                Expect.fail "Expected arc"

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes arc status tbr" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":1,"saga":"East Blue","title":"East Blue","description":"Desc.","status":"tbr","episodes":[]}],"processedEpisodes":0,"monitoredEpisodes":0,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                Expect.equal Planned arc.status

                            Nothing ->
                                Expect.fail "Expected arc"

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes arc status wip" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":2,"saga":"East Blue","title":"East Blue","description":"Desc.","status":"wip","episodes":[]}],"processedEpisodes":0,"monitoredEpisodes":0,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                Expect.equal InProgress arc.status

                            Nothing ->
                                Expect.fail "Expected arc"

                    Err err ->
                        Expect.fail (Decode.errorToString err)
        , test "decodes unknown arc status gracefully" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[{"arc":1,"saga":"East Blue","title":"East Blue","description":"Desc.","status":"archived","episodes":[]}],"processedEpisodes":0,"monitoredEpisodes":0,"status":"DONE"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case List.head report.monitored of
                            Just arc ->
                                case arc.status of
                                    UnknownArcStatus raw ->
                                        Expect.equal "archived" raw

                                    _ ->
                                        Expect.fail "Expected UnknownArcStatus"

                            Nothing ->
                                Expect.fail "Expected arc"

                    Err err ->
                        Expect.fail ("Decode should not fail: " ++ Decode.errorToString err)
        , test "decodes unknown pipeline status gracefully" <|
            \_ ->
                let
                    json =
                        """{"created":"2026-08-18T17:54:48.151Z","monitored":[],"processedEpisodes":0,"monitoredEpisodes":0,"status":"PARTIAL"}"""

                    result =
                        Decode.decodeString pipelineReportDecoder json
                in
                case result of
                    Ok report ->
                        case report.status of
                            UnknownPipelineStatus raw ->
                                Expect.equal "PARTIAL" raw

                            _ ->
                                Expect.fail "Expected UnknownPipelineStatus"

                    Err err ->
                        Expect.fail ("Decode should not fail: " ++ Decode.errorToString err)
        ]
