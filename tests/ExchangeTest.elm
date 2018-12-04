module ExchangeTest exposing (suite)

import Dict
import Exchange exposing (Exchange, decodeExchange)
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
                            "SGD":1.583124,
                            "USD":1.157271,
                            "VND":26540.852183
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
                                , ( "USD", 1.157271 )
                                , ( "VND", 26540.852183 )
                                ]
                        }
                in
                Expect.equal
                    (Decode.decodeString decodeExchange input)
                    (Ok result)
        , todo "Round trip decoding/encoding of Exchange type"
        ]
