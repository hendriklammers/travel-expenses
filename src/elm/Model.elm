module Model exposing (Model, initial, update)

import Task
import Date
import Messages exposing (Msg(..))
import Types exposing (..)
import Routing exposing (parseLocation)
import Random.Pcg exposing (Seed, initialSeed, step)
import Ports exposing (storeCurrency, storeExpenses)
import Uuid
import List.Extra exposing (find)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)


type alias Model =
    { amount : Float
    , category : Category
    , categories : List Category
    , currency : Currency
    , currencies : List Currency
    , seed : Seed
    , expenses : List Expense
    , error : Maybe Error
    , page : Page
    , menu : MenuState
    }


categories : List Category
categories =
    [ { id = 0
      , name = "Food & Drink"
      }
    , { id = 1
      , name = "Accomodation"
      }
    , { id = 2
      , name = "Transportation"
      }
    , { id = 3
      , name = "Shopping"
      }
    , { id = 4
      , name = "Trips & Attractions"
      }
    , { id = 5
      , name = "Other"
      }
    ]


currencies : List Currency
currencies =
    [ { code = "USD"
      , name = "United States Dollar"
      }
    , { code = "EUR"
      , name = "Euro"
      }
    , { code = "THB"
      , name = "Thai Baht"
      }
    , { code = "VND"
      , name = "Vietnamese Dong"
      }
    , { code = "KHR"
      , name = "Cambodian Riel"
      }
    , { code = "LAK"
      , name = "Laotian Kip"
      }
    , { code = "MYR"
      , name = "Malaysian Ringgit"
      }
    , { code = "SGD"
      , name = "Singapore Dollar"
      }
    , { code = "IDR"
      , name = "Indonesian Rupiah"
      }
    ]


initial : Flags -> Page -> Model
initial flags page =
    let
        currency =
            case flags.currency of
                Just c ->
                    c

                Nothing ->
                    { code = "USD"
                    , name = "United States Dollar"
                    }

        expenses =
            case flags.expenses of
                Just json ->
                    case Decode.decodeString decodeExpenses json of
                        Ok result ->
                            result

                        Err error ->
                            let
                                log =
                                    Debug.log "expenses" error
                            in
                                []

                Nothing ->
                    []
    in
        { amount = 0
        , category =
            { id = 0
            , name = "Food & Drink"
            }
        , categories = categories
        , currency = currency
        , currencies = currencies
        , seed = initialSeed flags.seed
        , expenses = expenses
        , error = Nothing
        , page = page
        , menu = MenuClosed
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAmount value ->
            let
                amount =
                    case String.toFloat value of
                        Ok result ->
                            result

                        Err _ ->
                            0
            in
                { model | amount = amount } ! []

        Submit ->
            if model.amount <= 0 then
                handleError
                    model
                    AmountError
                    "Please enter the amount of money spent"
            else
                ( model, Task.perform AddExpense Date.now )

        AddExpense date ->
            addExpense model date

        SelectCategory category ->
            { model | category = category } ! []

        SelectCurrency selected ->
            case find (\{ code } -> selected == code) model.currencies of
                Just currency ->
                    ( { model | currency = currency }, storeCurrency currency )

                Nothing ->
                    handleError
                        model
                        CurrencyError
                        "Invalid currency selected"

        CloseError ->
            { model | error = Nothing } ! []

        ToggleMenu ->
            let
                state =
                    case model.menu of
                        MenuOpen ->
                            MenuClosed

                        MenuClosed ->
                            MenuOpen
            in
                { model | menu = state } ! []

        LocationChange location ->
            { model | page = parseLocation location, menu = MenuClosed } ! []


addExpense : Model -> Date.Date -> ( Model, Cmd Msg )
addExpense model date =
    let
        ( id, seed ) =
            step Uuid.uuidGenerator model.seed

        expenses =
            { category = model.category
            , amount = model.amount
            , currency = model.currency
            , date = date
            , id = id
            }
                :: model.expenses
    in
        ( { model
            | seed = seed
            , amount = 0
            , error = Nothing
            , expenses = expenses
          }
        , storeExpenses (encodeExpenses expenses)
        )


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


handleError : Model -> ErrorType -> String -> ( Model, Cmd Msg )
handleError model error message =
    { model | error = Just ( error, message ) } ! []
