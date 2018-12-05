module ExpenseTest exposing (suite)

import Expect
import Expense
    exposing
        ( Category
        , Currency
        , Expense
        , categoryDecoder
        , categoryEncoder
        , currencyDecoder
        , currencyEncoder
        , expenseDecoder
        , expenseEncoder
        , expenseListDecoder
        , expenseListEncoder
        )
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Random exposing (step)
import Test exposing (..)
import Time exposing (Posix, millisToPosix)
import Uuid


suite : Test
suite =
    describe "Expense module"
        [ testCurrency
        , testCategory
        , testExpense
        , testExpenseList
        , testDateFilter
        ]


currencyFuzzer : Fuzzer Currency
currencyFuzzer =
    Fuzz.map2 Currency
        Fuzz.string
        Fuzz.string


testCurrency : Test
testCurrency =
    describe "JSON encoding/decoding Currency"
        [ test "Decodes json string into Currency" <|
            \_ ->
                let
                    input =
                        """
                        {
                            "code": "THB",
                            "name": "Thai Baht"
                        }
                        """

                    output =
                        Decode.decodeString currencyDecoder input
                in
                Expect.equal output
                    (Ok (Currency "THB" "Thai Baht"))
        , fuzz currencyFuzzer "round trip" <|
            \currency ->
                currency
                    |> currencyEncoder
                    |> Decode.decodeValue currencyDecoder
                    |> Expect.equal (Ok currency)
        ]


categoryFuzzer : Fuzzer Category
categoryFuzzer =
    Fuzz.map2 Category
        Fuzz.string
        Fuzz.string


testCategory : Test
testCategory =
    describe "JSON encoding/decoding Category"
        [ test "Decodes json string into Category" <|
            \_ ->
                let
                    input =
                        """
                        {
                            "id": "92149113-B678-4EEE-ACB6-E346990A35B8",
                            "name": "Transportation"
                        }
                        """

                    output =
                        Decode.decodeString categoryDecoder input
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
                    |> categoryEncoder
                    |> Decode.decodeValue categoryDecoder
                    |> Expect.equal (Ok category)
        ]


dateFuzzer : Fuzzer Posix
dateFuzzer =
    Fuzz.map millisToPosix (Fuzz.intRange 0 1543984297000)


buildUuid : Int -> Uuid.Uuid
buildUuid integer =
    let
        initialSeed =
            Random.initialSeed integer

        ( uuid, _ ) =
            step Uuid.uuidGenerator initialSeed
    in
    uuid


uuidFuzzer : Fuzzer Uuid.Uuid
uuidFuzzer =
    Fuzz.map buildUuid Fuzz.int


expenseFuzzer : Fuzzer Expense
expenseFuzzer =
    Fuzz.map5 Expense
        uuidFuzzer
        dateFuzzer
        Fuzz.float
        categoryFuzzer
        currencyFuzzer


testExpense : Test
testExpense =
    describe "JSON encoding/decoding Expense"
        [ fuzz expenseFuzzer "round trip" <|
            \expense ->
                expense
                    |> expenseEncoder
                    |> Decode.decodeValue expenseDecoder
                    |> Expect.equal (Ok expense)
        ]


expenseListFuzzer : Fuzzer (List Expense)
expenseListFuzzer =
    Fuzz.list expenseFuzzer


testExpenseList : Test
testExpenseList =
    describe "JSON encoding/decoding a list of Expenses"
        [ fuzz expenseListFuzzer "round trip" <|
            \expenses ->
                expenses
                    |> expenseListEncoder
                    |> Decode.decodeString expenseListDecoder
                    |> Expect.equal (Ok expenses)
        ]


testDateFilter : Test
testDateFilter =
    describe "Filter expenses between date range"
        [ todo "Expenses with date outside of range should be filtered out"
        ]
