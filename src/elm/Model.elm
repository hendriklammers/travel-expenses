module Model exposing
    ( Error
    , ErrorType(..)
    , Flags
    , MenuState(..)
    , Model
    , init
    , update
    )

import Browser
import Browser.Navigation as Nav
import Exchange exposing (Exchange, decodeExchange)
import Expense
    exposing
        ( Category
        , Currency
        , Expense
        , currencyDecoder
        , encodeCurrency
        , encodeExpenseList
        , expenseListDecoder
        )
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra exposing (find)
import Messages exposing (Msg(..))
import Ports exposing (storeCurrency, storeExpenses)
import Random exposing (Seed, initialSeed, step)
import Route exposing (Route(..), toRoute)
import Task
import Time
import Url
import Uuid


type MenuState
    = MenuOpen
    | MenuClosed


type ErrorType
    = InputError
    | FetchError


type alias Error =
    ( ErrorType, String )


type alias Vars =
    { fixer_api_key : Maybe String
    }


type alias Model =
    { amount : Maybe Float
    , category : Maybe Category
    , categories : List Category
    , currency : Maybe Currency
    , currencies : List Currency
    , seed : Seed
    , expenses : List Expense
    , error : Maybe Error
    , key : Nav.Key
    , route : Route
    , menu : MenuState
    , exchange : Maybe Exchange
    , vars : Vars
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


type alias Flags =
    { seed : Int
    , currency : Maybe String
    , expenses : Maybe String
    , fixer_api_key : Maybe String
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        currency =
            case flags.currency of
                Just json ->
                    case Decode.decodeString currencyDecoder json of
                        Ok result ->
                            Just result

                        Err error ->
                            -- TODO: Show message in UI
                            let
                                log =
                                    Debug.log "currency" error
                            in
                            List.head currencies

                Nothing ->
                    List.head currencies

        expenses =
            case flags.expenses of
                Just json ->
                    case Decode.decodeString expenseListDecoder json of
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
    ( { amount = Nothing
      , category = List.head categories
      , categories = categories
      , currency = currency
      , currencies = currencies
      , seed = initialSeed flags.seed
      , expenses = expenses
      , error = Nothing
      , key = key
      , route = toRoute url
      , menu = MenuClosed
      , exchange = Nothing
      , vars = Vars flags.fixer_api_key
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAmount value ->
            ( { model | amount = String.toFloat value }
            , Cmd.none
            )

        Submit ->
            ( model, Task.perform AddExpense Time.now )

        AddExpense date ->
            addExpense model date

        SelectCategory category ->
            ( { model | category = Just category }
            , Cmd.none
            )

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
                    ( { model | currency = Just currency }, cmd )

                Nothing ->
                    handleError
                        model
                        InputError
                        "Invalid currency selected"

        CloseError ->
            ( { model | error = Nothing }
            , Cmd.none
            )

        ToggleMenu ->
            let
                state =
                    case model.menu of
                        MenuOpen ->
                            MenuClosed

                        MenuClosed ->
                            MenuOpen
            in
            ( { model | menu = state }
            , Cmd.none
            )

        NewRates result ->
            case result of
                Ok exchange ->
                    ( { model | exchange = Just (Debug.log "exchange" exchange) }
                    , Cmd.none
                    )

                Err error ->
                    let
                        log =
                            Debug.log "http" error
                    in
                    handleError
                        model
                        FetchError
                        "Unable to fetch the exchange rates from the fixer.io API"

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model
                | route = toRoute url
                , menu = MenuClosed
              }
            , Cmd.none
            )


fetchRates : Maybe String -> Cmd Msg
fetchRates apiKey =
    let
        url =
            case apiKey of
                Just key ->
                    "http://data.fixer.io/api/latest?access_key=" ++ key ++ "&format=1"

                Nothing ->
                    "http://localhost:4000/exchange"

        request =
            Http.get url decodeExchange
    in
    Http.send NewRates request


addExpense : Model -> Time.Posix -> ( Model, Cmd Msg )
addExpense model date =
    let
        ( id, seed ) =
            step Uuid.uuidGenerator model.seed
    in
    case
        Maybe.map3
            (Expense id date)
            model.amount
            model.category
            model.currency
    of
        Just e ->
            ( { model
                | seed = seed
                , amount = Nothing
                , error = Nothing
                , expenses = e :: model.expenses
              }
            , storeExpenses (encodeExpenseList (e :: model.expenses))
            )

        Nothing ->
            handleError
                model
                InputError
                "Invalid input"


handleError : Model -> ErrorType -> String -> ( Model, Cmd Msg )
handleError model error message =
    ( { model | error = Just ( error, message ) }
    , Cmd.none
    )
