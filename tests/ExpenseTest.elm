module ExpenseTest exposing (suite)

import Expect
import Expense
    exposing
        ( Category
        , Currency
        , decodeCategory
        , decodeCurrency
        , decodeExpense
        , encodeCategory
        , encodeCurrency
        , encodeExpense
        )
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Test exposing (..)


suite : Test
suite =
    describe "Expense module"
        [ testCurrency
        , testCategory
        , todo "Add tests for Expense decoder/encoder"
        ]


currencyFuzzer : Fuzzer Currency
currencyFuzzer =
    Fuzz.map2 Currency
        Fuzz.string
        Fuzz.string


testCurrency : Test
testCurrency =
    describe "Currency"
        [ test "Decodes json string into Currency" <|
            \() ->
                let
                    input =
                        """
                        {
                            "code": "THB",
                            "name": "Thai Baht"
                        }
                        """

                    output =
                        Decode.decodeString decodeCurrency input
                in
                Expect.equal output
                    (Ok (Currency "THB" "Thai Baht"))
        , fuzz currencyFuzzer "round trip" <|
            \currency ->
                currency
                    |> encodeCurrency
                    |> Decode.decodeValue decodeCurrency
                    |> Expect.equal (Ok currency)
        ]


categoryFuzzer : Fuzzer Category
categoryFuzzer =
    Fuzz.map2 Category
        Fuzz.string
        Fuzz.string


testCategory : Test
testCategory =
    describe "Category"
        [ test "Decodes json string into Category" <|
            \() ->
                let
                    input =
                        """
                        {
                            "id": "92149113-B678-4EEE-ACB6-E346990A35B8",
                            "name": "Transportation"
                        }
                        """

                    output =
                        Decode.decodeString decodeCategory input
                in
                Expect.equal output
                    (Ok
                        (Category
                            "92149113-B678-4EEE-ACB6-E346990A35B8"
                            "Transportation"
                        )
                    )
        , fuzz categoryFuzzer "round trip" <|
            \category ->
                category
                    |> encodeCategory
                    |> Decode.decodeValue decodeCategory
                    |> Expect.equal (Ok category)
        ]



-- testExpense : Test
-- testExpense =
--     describe "Expense"
--         [ fuzz expenseFuzzer "round trip" <|
--             \expense ->
--                 expense
--                     |> encodeExpense
--                     |> Decode.decodeValue decodeExpense
--                     |> Expect.equal (Ok expense)
--         ]
