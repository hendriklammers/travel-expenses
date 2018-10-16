module Exchange exposing (Exchange, decodeExchange)

import Json.Decode as Decode exposing (Decoder)
import Time exposing (Posix)


type alias Exchange =
    -- { timestamp : Posix
    { rates : List Rate
    }


type alias Rate =
    ( String, Float )



-- decodeDate : Decoder Posix
-- decodeDate =
--     Decode.andThen dateFromFloat Decode.float
-- dateFromFloat : Float -> Decoder Posix
-- dateFromFloat date =
--     Decode.succeed (Time.millisToPosix date)


decodeRates : Decoder (List Rate)
decodeRates =
    Decode.keyValuePairs Decode.float


decodeExchange : Decoder Exchange
decodeExchange =
    Decode.map Exchange
        -- (Decode.field "timestamp" decodeDate)
        (Decode.field "rates" decodeRates)



-- TODO: Add encoder
