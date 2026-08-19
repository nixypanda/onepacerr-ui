module Data.Health exposing
    ( Health
    , Posix
    )

import Json.Decode as Decode exposing (Decoder)


type alias Health =
    { name : String
    , httpCode : Int
    , message : String
    }


type alias Posix =
    Int