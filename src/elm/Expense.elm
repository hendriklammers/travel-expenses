module Expense exposing
    ( Category
    , Currencies
    , Currency
    , Expense
    , categoryDecoder
    , categoryEncoder
    , currencyDecoder
    , currencyEncoder
    , currencyListDecoder
    , currencyListEncoder
    , dateDecoder
    , downloadExpenses
    , expenseDecoder
    , expenseEncoder
    , expenseListDecoder
    , expenseListEncoder
    , filterDates
    )

import Date exposing (Date)
import Dict exposing (Dict)
import File.Download as Download
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Location
    exposing
        ( Location(..)
        , LocationData
        , locationDataDecoder
        , locationDataEncoder
        )
import Time exposing (Posix)
import Uuid


type alias Category =
    { id : String
    , name : String
    }


categoryEncoder : Category -> Encode.Value
categoryEncoder { id, name } =
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
    , active : Bool
    , selected : Bool
    }


type alias Currencies =
    Dict String Currency


currencyEncoder : Currency -> Encode.Value
currencyEncoder { code, name } =
    Encode.object
        [ ( "code", Encode.string code )
        , ( "name", Encode.string name )
        ]


currencyListEncoder : Int -> List Currency -> String
currencyListEncoder indentation currencies =
    currencies
        |> Encode.list currencyEncoder
        |> Encode.encode indentation


currencyDecoder : Decoder Currency
currencyDecoder =
    Decode.map4 Currency
        (Decode.field "code" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.succeed False)
        (Decode.succeed False)


currencyListDecoder : Decoder (List Currency)
currencyListDecoder =
    Decode.list currencyDecoder


type alias Expense =
    { id : Uuid.Uuid
    , date : Posix
    , amount : Float
    , category : Category
    , currency : Currency
    , location : Maybe LocationData
    }


expenseEncoder : Expense -> Encode.Value
expenseEncoder { category, amount, currency, id, date, location } =
    Encode.object
        ([ ( "id", Uuid.encode id )
         , ( "date", Encode.int (Time.posixToMillis date) )
         , ( "amount", Encode.float amount )
         , ( "category", categoryEncoder category )
         , ( "currency", currencyEncoder currency )
         ]
            ++ (case location of
                    Just data ->
                        [ ( "location", locationDataEncoder data ) ]

                    _ ->
                        []
               )
        )


expenseListEncoder : Int -> List Expense -> String
expenseListEncoder indentation expenses =
    expenses
        |> Encode.list expenseEncoder
        |> Encode.encode indentation


expenseDecoder : Decoder Expense
expenseDecoder =
    Decode.map6 Expense
        (Decode.field "id" Uuid.decoder)
        (Decode.field "date" dateDecoder)
        (Decode.field "amount" Decode.float)
        (Decode.field "category" categoryDecoder)
        (Decode.field "currency" currencyDecoder)
        (Decode.maybe <| Decode.field "location" locationDataDecoder)


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


downloadExpenses : List Expense -> Cmd msg
downloadExpenses expenses =
    Download.string
        "expenses_export.json"
        "application/json"
        (expenseListEncoder 2 expenses)
