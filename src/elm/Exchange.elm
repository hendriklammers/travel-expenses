module Exchange exposing (Exchange, decodeExchange)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Time exposing (Posix)


type alias Exchange =
    { timestamp : Posix
    , rates : Dict String Float
    }


type alias Rate =
    ( String, Float )


decodeDate : Decoder Posix
decodeDate =
    Decode.andThen dateFromInt Decode.int


dateFromInt : Int -> Decoder Posix
dateFromInt date =
    Decode.succeed (Time.millisToPosix date)


decodeExchange : Decoder Exchange
decodeExchange =
    Decode.map2 Exchange
        (Decode.field "timestamp" decodeDate)
        (Decode.field "rates" <| Decode.dict Decode.float)



-- TODO: Add encoder
