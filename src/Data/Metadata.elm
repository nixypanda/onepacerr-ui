module Data.Metadata exposing
    ( Metadata
    , MetadataConfig
    )

import Data.Health exposing (Posix)


type alias MetadataConfig =
    { metadataUrl : String
    , metadataLanguage : String
    , metadataPosterSet : String
    , metadataCheckInterval : Int
    }


type alias Metadata =
    { url : String
    , configs : MetadataConfig
    , downloaded : Bool
    }