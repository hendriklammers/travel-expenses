module ExchangeTest exposing (suite)

import Dict exposing (Dict)
import Exchange exposing (Exchange, decodeExchange, encodeExchange)
import Expect
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Random exposing (step)
import Test exposing (..)
import Time exposing (Posix, millisToPosix)


suite : Test
suite =
    describe "Exchange module"
        [ testExchange
        ]


testExchange : Test
testExchange =
    describe "JSON encoding/decoding Exchange"
        [ test "Decodes json string into valid Exchange record" <|
            \_ ->
                let
                    input =
                        """
                        {
                        "timestamp":1530238449,
                        "rates":{
                            "EUR":1,
                            "JPY":127.854134,
                            "SGD":1.583124
                            }
                        }
                        """

                    result =
                        { timestamp = Time.millisToPosix 1530238449
                        , rates =
                            Dict.fromList
                                [ ( "EUR", 1 )
                                , ( "JPY", 127.854134 )
                                , ( "SGD", 1.583124 )
                                ]
                        }
                in
                Expect.equal
                    (Decode.decodeString decodeExchange input)
                    (Ok result)
        , fuzz exchangeFuzzer "round trip" <|
            \exchange ->
                exchange
                    |> encodeExchange
                    |> Decode.decodeString decodeExchange
                    |> Expect.equal (Ok exchange)
        ]


exchangeFuzzer : Fuzzer Exchange
exchangeFuzzer =
    Fuzz.map2 Exchange
        dateFuzzer
        ratesFuzzer


rateFuzzer : Fuzzer ( String, Float )
rateFuzzer =
    Fuzz.map2 Tuple.pair
        (Fuzz.constant "THB")
        (Fuzz.floatRange 0 1000000)


ratesFuzzer : Fuzzer (Dict String Float)
ratesFuzzer =
    Fuzz.map
        Dict.fromList
        (Fuzz.list rateFuzzer)


dateFuzzer : Fuzzer Posix
dateFuzzer =
    Fuzz.map millisToPosix (Fuzz.intRange 0 1543984297000)
