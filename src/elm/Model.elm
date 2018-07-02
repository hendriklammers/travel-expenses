module Model
    exposing
        ( Model
        , Flags
        , init
        , update
        , ErrorType(..)
        , Error
        , MenuState(..)
        )

import Task
import Date
import Messages exposing (Msg(..))
import Routing exposing (Page(..), parseLocation)
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
import Exchange exposing (decodeExchange, Exchange)
import Json.Encode as Encode
import Json.Decode as Decode
import Http
import Navigation exposing (Location)


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
    , page : Page
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


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            parseLocation location

        cmd =
            if page == OverviewPage then
                Task.perform FetchExchangeRates Date.now
            else
                Cmd.none
    in
        ( initial flags page, cmd )


initial : Flags -> Page -> Model
initial flags page =
    let
        currency =
            case flags.currency of
                Just json ->
                    case Decode.decodeString decodeCurrency json of
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
        { amount = Nothing
        , category = List.head categories
        , categories = categories
        , currency = currency
        , currencies = currencies
        , seed = initialSeed flags.seed
        , expenses = expenses
        , error = Nothing
        , page = page
        , menu = MenuClosed
        , exchange = Nothing
        , vars =
            Vars
                flags.fixer_api_key
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAmount value ->
            let
                amount =
                    case String.toFloat value of
                        Ok result ->
                            Just result

                        Err _ ->
                            Nothing
            in
                { model | amount = amount } ! []

        Submit ->
            ( model, Task.perform AddExpense Date.now )

        AddExpense date ->
            addExpense model date

        SelectCategory category ->
            { model | category = Just category } ! []

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
            let
                page =
                    parseLocation location

                cmd =
                    if page == OverviewPage then
                        {- Fetch exchange rates when going to overview page -}
                        Task.perform FetchExchangeRates Date.now
                    else
                        Cmd.none
            in
                ( { model | page = page, menu = MenuClosed }, cmd )

        FetchExchangeRates date ->
            let
                shouldFetch =
                    True

                cmd =
                    Cmd.none

                { fixer_api_key } =
                    model.vars
            in
                ( model, fetchRates fixer_api_key )

        NewRates result ->
            case result of
                Ok exchange ->
                    { model | exchange = Just (Debug.log "exchange" exchange) } ! []

                Err error ->
                    let
                        log =
                            Debug.log "http" error
                    in
                        handleError
                            model
                            FetchError
                            "Unable to fetch the exchange rates from the fixer.io API"


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


addExpense : Model -> Date.Date -> ( Model, Cmd Msg )
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
                , storeExpenses (encodeExpenses (e :: model.expenses))
                )

            Nothing ->
                handleError
                    model
                    InputError
                    "Invalid input"


handleError : Model -> ErrorType -> String -> ( Model, Cmd Msg )
handleError model error message =
    { model | error = Just ( error, message ) } ! []
