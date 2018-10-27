module Expense exposing
    ( Category
    , Currency
    , Expense
    , categoryDecoder
    , currencyDecoder
    , dateDecoder
    , encodeCategory
    , encodeCurrency
    , encodeExpense
    , encodeExpenseList
    , expenseDecoder
    , expenseListDecoder
    , filterDates
    )

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Time exposing (Posix)
import Uuid


type alias Category =
    { id : String
    , name : String
    }


encodeCategory : Category -> Encode.Value
encodeCategory { id, name } =
    Encode.object
        [ ( "id", Encode.string id )
        , ( "name", Encode.string name )
        ]


categoryDecoder : Decoder Category
categoryDecoder =
    Decode.map2 Category
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)


type alias Currency =
    { code : String
    , name : String
    }


encodeCurrency : Currency -> Encode.Value
encodeCurrency { code, name } =
    Encode.object
        [ ( "code", Encode.string code )
        , ( "name", Encode.string name )
        ]


currencyDecoder : Decoder Currency
currencyDecoder =
    Decode.map2 Currency
        (Decode.field "code" Decode.string)
        (Decode.field "name" Decode.string)


type alias Expense =
    { id : Uuid.Uuid
    , date : Posix
    , amount : Float
    , category : Category
    , currency : Currency
    }


encodeExpense : Expense -> Encode.Value
encodeExpense { category, amount, currency, id, date } =
    Encode.object
        [ ( "id", Uuid.encode id )
        , ( "date", Encode.int (Time.posixToMillis date) )
        , ( "amount", Encode.float amount )
        , ( "category", encodeCategory category )
        , ( "currency", encodeCurrency currency )
        ]


encodeExpenseList : List Expense -> String
encodeExpenseList expenses =
    expenses
        |> Encode.list encodeExpense
        |> Encode.encode 0


expenseDecoder : Decoder Expense
expenseDecoder =
    Decode.map5 Expense
        (Decode.field "id" Uuid.decoder)
        (Decode.field "date" dateDecoder)
        (Decode.field "amount" Decode.float)
        (Decode.field "category" categoryDecoder)
        (Decode.field "currency" currencyDecoder)


expenseListDecoder : Decoder (List Expense)
expenseListDecoder =
    Decode.list expenseDecoder


dateDecoder : Decoder Posix
dateDecoder =
    Decode.andThen
        (\date -> Decode.succeed (Time.millisToPosix date))
        Decode.int


filterDates : ( Maybe Date, Maybe Date ) -> List Expense -> List Expense
filterDates dateRange expenses =
    -- Only filter when start and end date are given
    case dateRange of
        ( Just startDate, Just endDate ) ->
            List.filter
                (.date
                    >> Date.fromPosix Time.utc
                    >> Date.isBetween startDate endDate
                )
                expenses

        _ ->
            expenses
