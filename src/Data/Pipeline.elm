module Data.Pipeline exposing
    ( PipelineStatus(..)
    , ArcStatus(..)
    , PipelineConfig
    , PipelineReport
    , MonitoredArc
    , Episode
    , EpisodeFiles
    , FileInfo
    , ArchivedFile
    )

import Data.Health exposing (Posix)


type PipelineStatus
    = Pre
    | Ready
    | Running
    | Done
    | Errored
    | UnknownPipelineStatus String


type ArcStatus
    = Complete
    | InProgress
    | Planned
    | UnknownArcStatus String


type alias PipelineConfig =
    { skipVerifyPresentFiles : Bool
    , skipVerifyNotForExtended : Bool
    , skipOrganizePresentFiles : Bool
    , skipUpdateMetadataPresentFiles : Bool
    , skipDownloads : Bool
    , skipDownloadsImports : Bool
    , forceRedownload : Bool
    , skipPosters : Bool
    , includeSpecials : Bool
    , preferExtended : Bool
    , preferAlternate : Bool
    , retryInterval : Int
    }


type alias PipelineReport =
    { created : Posix
    , started : Maybe Posix
    , ended : Maybe Posix
    , monitored : List MonitoredArc
    , processedEpisodes : Int
    , monitoredEpisodes : Int
    , status : PipelineStatus
    , error : Maybe String
    }


type alias MonitoredArc =
    { arc : Int
    , saga : String
    , title : String
    , description : String
    , status : ArcStatus
    , episodes : List Episode
    }


type alias Episode =
    { arc : Int
    , episode : Int
    , title : String
    , description : Maybe String
    , released : Maybe Posix
    , mangaChapters : Maybe String
    , animeEpisodes : Maybe String
    , files : EpisodeFiles
    }


type alias EpisodeFiles =
    { standard : FileInfo
    , extended : Maybe FileInfo
    , archived : List ArchivedFile
    }


type alias FileInfo =
    { crc32 : String
    , hash : String
    , magnetUri : String
    , duration : Maybe Int
    , variant : String
    , partOfBundle : Maybe Bool
    , crc32InFileName : Maybe String
    }


type alias ArchivedFile =
    { crc32 : String
    , hash : String
    , magnetUri : String
    , variant : String
    , outdated : Bool
    , partOfBundle : Maybe Bool
    }