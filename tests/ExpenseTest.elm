module ExpenseTest exposing (suite)

import Date
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
        , filterDates
        )
import Fuzz exposing (Fuzzer)
import Json.Decode as Decode
import Random exposing (step)
import Test exposing (..)
import Time exposing (Month(..), Posix, millisToPosix)
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


generateUuid : Int -> Uuid.Uuid
generateUuid integer =
    let
        initialSeed =
            Random.initialSeed integer

        ( uuid, _ ) =
            step Uuid.uuidGenerator initialSeed
    in
    uuid


uuidFuzzer : Fuzzer Uuid.Uuid
uuidFuzzer =
    Fuzz.map generateUuid Fuzz.int


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
            \list ->
                list
                    |> expenseListEncoder 0
                    |> Decode.decodeString expenseListDecoder
                    |> Expect.equal (Ok list)
        ]


testDateFilter : Test
testDateFilter =
    describe "Filter expenses between date range"
        [ test "No filtering when no dates are supplied" <|
            \_ ->
                Expect.equal
                    (filterDates ( Nothing, Nothing ) expenses)
                    expenses
        , test "No filtering when only start date is supplied" <|
            \_ ->
                Expect.equal
                    (filterDates
                        ( Just (Date.fromCalendarDate 2018 Nov 28)
                        , Nothing
                        )
                        expenses
                    )
                    expenses
        , test "No filtering when only end date is supplied" <|
            \_ ->
                Expect.equal
                    (filterDates
                        ( Nothing
                        , Just (Date.fromCalendarDate 2018 Nov 28)
                        )
                        expenses
                    )
                    expenses
        , test "Filter out dates before start date" <|
            \_ ->
                Expect.equal
                    (filterDates
                        ( Just (Date.fromCalendarDate 2018 Nov 28)
                        , Just (Date.fromCalendarDate 2018 Dec 5)
                        )
                        expenses
                    )
                    [ { id = generateUuid 3
                      , date = millisToPosix 1543932000000
                      , amount = 15
                      , category =
                            Category
                                "5772822A-42B4-4605-A5C3-0504498C3432"
                                "Food & Drink"
                      , currency = Currency "MYR" "Malaysian Ringgit"
                      }
                    , { id = generateUuid 3
                      , date = millisToPosix 1543683600000
                      , amount = 12
                      , category =
                            Category
                                "5772822A-42B4-4605-A5C3-0504498C3432"
                                "Food & Drink"
                      , currency = Currency "MYR" "Malaysian Ringgit"
                      }
                    ]
        , test "Filter out dates after end date" <|
            \_ ->
                Expect.equal
                    (filterDates
                        ( Just (Date.fromCalendarDate 2018 Nov 1)
                        , Just (Date.fromCalendarDate 2018 Nov 28)
                        )
                        expenses
                    )
                    [ { id = generateUuid 3
                      , date = millisToPosix 1543208400000
                      , amount = 27
                      , category =
                            Category
                                "5772822A-42B4-4605-A5C3-0504498C3432"
                                "Food & Drink"
                      , currency = Currency "MYR" "Malaysian Ringgit"
                      }
                    ]
        , todo "Add fuzz test for dates filter"
        ]


expenses : List Expense
expenses =
    [ { id = generateUuid 3
      , date = millisToPosix 1543932000000
      , amount = 15
      , category =
            Category
                "5772822A-42B4-4605-A5C3-0504498C3432"
                "Food & Drink"
      , currency = Currency "MYR" "Malaysian Ringgit"
      }
    , { id = generateUuid 3
      , date = millisToPosix 1543683600000
      , amount = 12
      , category =
            Category
                "5772822A-42B4-4605-A5C3-0504498C3432"
                "Food & Drink"
      , currency = Currency "MYR" "Malaysian Ringgit"
      }
    , { id = generateUuid 3
      , date = millisToPosix 1543208400000
      , amount = 27
      , category =
            Category
                "5772822A-42B4-4605-A5C3-0504498C3432"
                "Food & Drink"
      , currency = Currency "MYR" "Malaysian Ringgit"
      }
    ]
