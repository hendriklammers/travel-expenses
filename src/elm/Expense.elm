module Expense exposing
    ( Category
    , Currency
    , Expense
    , decodeCurrency
    , decodeExpenses
    , encodeCurrency
    , encodeExpenses
    )

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


decodeCategory : Decoder Category
decodeCategory =
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


decodeCurrency : Decoder Currency
decodeCurrency =
    Decode.map2 Currency
        (Decode.field "code" Decode.string)
        (Decode.field "name" Decode.string)


type alias Expense =
    { id : Uuid.Uuid

    -- , date : Posix
    , amount : Float
    , category : Category
    , currency : Currency
    }


encodeExpense : Expense -> Encode.Value
encodeExpense { category, amount, currency, id } =
    Encode.object
        [ ( "id", Uuid.encode id )

        -- , ( "date", Encode.float (Time.millisToPosix date) )
        , ( "amount", Encode.float amount )
        , ( "category", encodeCategory category )
        , ( "currency", encodeCurrency currency )
        ]


decodeExpense : Decoder Expense
decodeExpense =
    Decode.map4 Expense
        (Decode.field "id" Uuid.decoder)
        -- (Decode.field "date" decodeDate)
        (Decode.field "amount" Decode.float)
        (Decode.field "category" decodeCategory)
        (Decode.field "currency" decodeCurrency)


encodeExpenses : List Expense -> String
encodeExpenses expenses =
    expenses
        |> Encode.list encodeExpense
        |> Encode.encode 0


decodeExpenses : Decoder (List Expense)
decodeExpenses =
    Decode.list decodeExpense



-- decodeDate : Decoder Posix
-- decodeDate =
--     Decode.andThen dateFromFloat Decode.float
-- dateFromFloat : Float -> Decoder Posix
-- dateFromFloat date =
--     Decode.succeed (Time.millisToPosix date)
