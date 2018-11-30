module Exchange exposing (Exchange, decodeExchange, encodeExchange)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Time exposing (Posix)


type alias Exchange =
    { timestamp : Posix
    , rates : Dict String Float
    }


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


encodeRates : Dict String Float -> Encode.Value
encodeRates rates =
    Dict.toList rates
        |> List.map (\( key, val ) -> ( key, Encode.float val ))
        |> Encode.object


encodeExchange : Exchange -> String
encodeExchange { timestamp, rates } =
    Encode.object
        [ ( "timestamp", Encode.int (Time.posixToMillis timestamp) )
        , ( "rates", encodeRates rates )
        ]
        |> Encode.encode 0
