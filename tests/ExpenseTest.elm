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
import Location exposing (LocationData, locationDataDecoder, locationDataEncoder)
import Random exposing (step)
import Test exposing (Test, describe, fuzz, test, todo)
import Time exposing (Month(..), Posix, millisToPosix)
import Uuid


suite : Test
suite =
    describe "Expense module"
        [ testCurrency
        , testCategory
        , testLocationData
        , testExpense
        , testExpenseList
        , testDateFilter
        ]


currencyFuzzer : Fuzzer Currency
currencyFuzzer =
    Fuzz.map4 Currency
        Fuzz.string
        Fuzz.string
        (Fuzz.constant False)
        (Fuzz.constant False)


testCurrency : Test
testCurrency =
    describe "JSON encoding/decoding Currency"
        [ test "Decodes json string into Currency" <|
            \_ ->
                let
                    input =
                        Decode.decodeString
                            currencyDecoder
                            """
                            {
                                "code": "THB",
                                "name": "Thai Baht"
                            }
                            """
                in
                Expect.equal
                    input
                    (Ok (Currency "THB" "Thai Baht" False False))
        , fuzz currencyFuzzer "round trip" <|
            \currency ->
                currency
                    |> currencyEncoder
                    |> Decode.decodeValue currencyDecoder
                    |> Expect.equal
                        (Ok currency)
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
                    json =
                        """
                        {
                            "id": "92149113-B678-4EEE-ACB6-E346990A35B8",
                            "name": "Transportation"
                        }
                        """

                    input =
                        Decode.decodeString categoryDecoder json
                in
                Expect.equal input
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


locationDataFuzzer : Fuzzer LocationData
locationDataFuzzer =
    Fuzz.tuple ( Fuzz.float, Fuzz.float )


testLocationData : Test
testLocationData =
    describe "JSON encoding/decoding LocationData"
        [ test "Decode LocationData tuple into json" <|
            \_ ->
                let
                    json =
                        """
                        {
                            "latitude": 52.370216,
                            "longitude": 4.895168
                        }
                        """

                    input =
                        Decode.decodeString locationDataDecoder json
                in
                Expect.equal input
                    (Ok ( 52.370216, 4.895168 ))
        , fuzz locationDataFuzzer "round trip" <|
            \locationData ->
                locationData
                    |> locationDataEncoder
                    |> Decode.decodeValue locationDataDecoder
                    |> Expect.equal (Ok locationData)
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
    Fuzz.map Expense uuidFuzzer
        |> Fuzz.andMap dateFuzzer
        |> Fuzz.andMap Fuzz.float
        |> Fuzz.andMap categoryFuzzer
        |> Fuzz.andMap currencyFuzzer
        |> Fuzz.andMap (Fuzz.maybe locationDataFuzzer)


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
                      , currency = Currency "MYR" "Malaysian Ringgit" False False
                      , location = Nothing
                      }
                    , { id = generateUuid 3
                      , date = millisToPosix 1543683600000
                      , amount = 12
                      , category =
                            Category
                                "5772822A-42B4-4605-A5C3-0504498C3432"
                                "Food & Drink"
                      , currency = Currency "MYR" "Malaysian Ringgit" False False
                      , location = Just ( 14.015947299999999, 99.98238850000001 )
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
                      , currency = Currency "MYR" "Malaysian Ringgit" False False
                      , location = Just ( 14.015947299999999, 99.98238850000001 )
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
      , currency = Currency "MYR" "Malaysian Ringgit" False False
      , location = Nothing
      }
    , { id = generateUuid 3
      , date = millisToPosix 1543683600000
      , amount = 12
      , category =
            Category
                "5772822A-42B4-4605-A5C3-0504498C3432"
                "Food & Drink"
      , currency = Currency "MYR" "Malaysian Ringgit" False False
      , location = Just ( 14.015947299999999, 99.98238850000001 )
      }
    , { id = generateUuid 3
      , date = millisToPosix 1543208400000
      , amount = 27
      , category =
            Category
                "5772822A-42B4-4605-A5C3-0504498C3432"
                "Food & Drink"
      , currency = Currency "MYR" "Malaysian Ringgit" False False
      , location = Just ( 14.015947299999999, 99.98238850000001 )
      }
    ]
