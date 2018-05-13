module Expense
    exposing
        ( encodeExpenses
        , encodeCurrency
        , decodeExpenses
        , decodeCurrency
        )

import Date
import Types exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Uuid


encodeCategory : Category -> Encode.Value
encodeCategory { id, name } =
    Encode.object
        [ ( "id", Encode.int id )
        , ( "name", Encode.string name )
        ]


decodeCategory : Decoder Category
decodeCategory =
    Decode.map2 Category
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)


encodeCurrency : Currency -> Encode.Value
encodeCurrency { code, name } =
    Encode.object
        [ ( "code", Encode.string code )
        , ( "name", Encode.string name )
        ]


decodeCurrency : Decoder Currency
decodeCurrency =
    Decode.map2 Currency
        (Decode.field "code" Decode.string)
        (Decode.field "name" Decode.string)


encodeExpense : Expense -> Encode.Value
encodeExpense { category, amount, currency, date, id } =
    Encode.object
        [ ( "category", encodeCategory category )
        , ( "amount", Encode.float amount )
        , ( "currency", encodeCurrency currency )
        , ( "date", Encode.float (Date.toTime date) )
        , ( "id", Uuid.encode id )
        ]


decodeDate : Decoder Date.Date
decodeDate =
    Decode.andThen dateFromFloat Decode.float


dateFromFloat : Float -> Decoder Date.Date
dateFromFloat date =
    Decode.succeed (Date.fromTime date)


decodeExpense : Decoder Expense
decodeExpense =
    Decode.map5 Expense
        (Decode.field "category" decodeCategory)
        (Decode.field "amount" Decode.float)
        (Decode.field "currency" decodeCurrency)
        (Decode.field "date" decodeDate)
        (Decode.field "id" Uuid.decoder)


encodeExpenses : List Expense -> String
encodeExpenses xs =
    List.map encodeExpense xs
        |> Encode.list
        |> Encode.encode 0


decodeExpenses : Decoder (List Expense)
decodeExpenses =
    Decode.list decodeExpense
