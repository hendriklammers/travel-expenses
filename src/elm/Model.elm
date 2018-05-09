module Model exposing (Model, initial, update)

import Task
import Date
import Messages exposing (Msg(..))
import Types exposing (..)
import Routing exposing (parseLocation)
import Random.Pcg exposing (Seed, initialSeed, step)
import Ports exposing (storeCurrency)
import Uuid
import List.Extra exposing (find)


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
        , expenses = []
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

        expense =
            { category = model.category
            , amount = model.amount
            , currency = model.currency
            , date = date
            , id = id
            }
    in
        { model
            | seed = seed
            , amount = 0
            , error = Nothing
            , expenses = expense :: model.expenses
        }
            ! []


handleError : Model -> ErrorType -> String -> ( Model, Cmd Msg )
handleError model error message =
    { model | error = Just ( error, message ) } ! []
