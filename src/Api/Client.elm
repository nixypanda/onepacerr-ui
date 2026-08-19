module Api.Client exposing
    ( ApiError(..)
    , get
    )

import Http
import Json.Decode as Decode
import Lib.Json


type ApiError
    = NetworkError
    | HttpError Int String
    | JsonDecodeError String
    | Timeout


get : String -> Decode.Decoder a -> Cmd (Result ApiError a)
get url decoder =
    Http.get
        { url = url
        , expect = Http.expectJson toResult decoder
        }


toResult : Result Http.Error a -> Result ApiError a
toResult result =
    case result of
        Ok value ->
            Ok value

        Err httpError ->
            case httpError of
                Http.BadUrl msg ->
                    Err (JsonDecodeError ("Bad URL: " ++ msg))

                Http.Timeout ->
                    Err Timeout

                Http.NetworkError ->
                    Err NetworkError

                Http.BadStatus statusCode ->
                    Err (HttpError statusCode ("HTTP " ++ String.fromInt statusCode))

                Http.BadBody body ->
                    Err (JsonDecodeError ("Bad body: " ++ body))