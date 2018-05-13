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
import Expense
    exposing
        ( Category
        , Currency
        , Expense
        , encodeExpenses
        , encodeCurrency
        , decodeExpenses
        , decodeCurrency
        )
import Json.Encode as Encode
import Json.Decode as Decode


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
    [ { id = "5772822A-42B4-4605-A5C3-0504498C3432"
      , name = "Food & Drink"
      }
    , { id = "E7C07380-2899-4979-84B2-087E68BAC60C"
      , name = "Accomodation"
      }
    , { id = "92149113-B678-4EEE-ACB6-E346990A35B8"
      , name = "Transportation"
      }
    , { id = "6E632105-8A84-490F-AD33-A543E51669AE"
      , name = "Shopping"
      }
    , { id = "43641EFB-97D3-482D-9A6D-E2193979E383"
      , name = "Trips & Attractions"
      }
    , { id = "6063E8E0-0190-4DF6-8B35-D5F332F799FA"
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



-- TODO: Remove hardcoded defaults for currency and category


initial : Flags -> Page -> Model
initial flags page =
    let
        currency =
            let
                default =
                    { code = "EUR"
                    , name = "Euro"
                    }
            in
                case flags.currency of
                    Just json ->
                        case Decode.decodeString decodeCurrency json of
                            Ok result ->
                                result

                            Err error ->
                                -- TODO: Show message in UI
                                let
                                    log =
                                        Debug.log "currency" error
                                in
                                    default

                    Nothing ->
                        default

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
            { id = "0"
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
                    let
                        cmd =
                            currency
                                |> encodeCurrency
                                |> Encode.encode 0
                                |> storeCurrency
                    in
                        ( { model | currency = currency }, cmd )

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


handleError : Model -> ErrorType -> String -> ( Model, Cmd Msg )
handleError model error message =
    { model | error = Just ( error, message ) } ! []
