module Exchange exposing (decodeExchange, Exchange)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)


type alias Exchange =
    { timestamp : Date
    , rates : List Rate
    }


type alias Rate =
    ( String, Float )


decodeDate : Decoder Date.Date
decodeDate =
    Decode.andThen dateFromFloat Decode.float


dateFromFloat : Float -> Decoder Date.Date
dateFromFloat date =
    Decode.succeed (Date.fromTime date)


decodeRates : Decoder (List Rate)
decodeRates =
    Decode.keyValuePairs Decode.float


decodeExchange : Decoder Exchange
decodeExchange =
    Decode.map2 Exchange
        (Decode.field "timestamp" decodeDate)
        (Decode.field "rates" decodeRates)



-- TODO: Add encoder
