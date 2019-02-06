module Model exposing
    ( Error
    , ErrorType(..)
    , Flags
    , MenuState(..)
    , Model
    , Msg(..)
    , Sort(..)
    , TableSort
    , endSettings
    , init
    , startSettings
    , update
    )

import Browser
import Browser.Navigation as Nav
import Date exposing (Date)
import DatePicker exposing (DateEvent(..), defaultSettings)
import Dict
import Exchange exposing (Exchange, exchangeDecoder, exchangeEncoder)
import Expense
    exposing
        ( Category
        , Currency
        , Expense
        , currencyDecoder
        , currencyEncoder
        , expenseListDecoder
        , expenseListEncoder
        )
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra exposing (find)
import Ports exposing (storeCurrency, storeExchange, storeExpenses)
import Random exposing (Seed, initialSeed, step)
import Route exposing (Route(..), toRoute)
import Task
import Time
import Url
import Url.Builder as Builder
import Uuid


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
    , startDate : Maybe Date
    , endDate : Maybe Date
    , startDatePicker : DatePicker.DatePicker
    , endDatePicker : DatePicker.DatePicker
    , timeZone : Time.Zone
    , fetchingExchange : Bool
    , overviewTableSort : TableSort
    , currencyTableSort : TableSort
    }


type Msg
    = UpdateAmount String
    | SelectCategory Category
    | SelectCurrency String
    | Submit
    | AddExpense Time.Posix
    | CloseError
    | ToggleMenu
    | NewRates (Result Http.Error Exchange)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ToStartDatePicker DatePicker.Msg
    | ToEndDatePicker DatePicker.Msg
    | LoadExchange
    | DeleteStartDate
    | DeleteEndDate
    | SetTimeZone Time.Zone
    | SetTimestamp Time.Posix
    | RowClick String
    | SortOverviewTable String
    | SortCurrencyTable String


type MenuState
    = MenuOpen
    | MenuClosed


type ErrorType
    = InputError
    | FetchError


type Sort
    = ASC
    | DESC


type alias TableSort =
    Maybe ( String, Sort )


type alias Error =
    ( ErrorType, String )


type alias Vars =
    { fixer_api_key : Maybe String
    }


type alias Flags =
    { seed : Int
    , currency : Maybe String
    , exchange : Maybe String
    , expenses : Maybe String
    , fixer_api_key : Maybe String
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


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    -- TODO: Cleanup code duplication
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

        exchange =
            case flags.exchange of
                Just json ->
                    case Decode.decodeString exchangeDecoder json of
                        Ok result ->
                            Just result

                        Err error ->
                            let
                                log =
                                    Debug.log "exchange" error
                            in
                            Nothing

                Nothing ->
                    Nothing

        ( startDatePicker, startDatePickerFx ) =
            DatePicker.init

        ( endDatePicker, endDatePickerFx ) =
            DatePicker.init
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
      , exchange = exchange
      , vars = Vars flags.fixer_api_key
      , startDate = Nothing
      , startDatePicker = startDatePicker
      , endDate = Nothing
      , endDatePicker = endDatePicker
      , timeZone = Time.utc
      , fetchingExchange = False
      , overviewTableSort = Nothing
      , currencyTableSort = Nothing
      }
    , Cmd.batch
        [ Cmd.map ToStartDatePicker startDatePickerFx
        , Cmd.map ToEndDatePicker endDatePickerFx
        , Task.perform SetTimeZone Time.here
        ]
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
                                |> currencyEncoder
                                |> Encode.encode 0
                                |> storeCurrency
                    in
                    ( { model | currency = Just currency }, cmd )

                Nothing ->
                    ( { model
                        | error =
                            Just
                                ( InputError
                                , "Invalid currency selected"
                                )
                      }
                    , Cmd.none
                    )

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
                    ( { model
                        | exchange = Just exchange
                        , fetchingExchange = False
                      }
                    , Task.perform SetTimestamp Time.now
                    )

                Err error ->
                    let
                        log =
                            Debug.log "http" error
                    in
                    ( { model
                        | fetchingExchange = False
                        , error =
                            Just
                                ( FetchError
                                , "Unable to fetch the exchange rates from the API"
                                )
                      }
                    , Cmd.none
                    )

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

        ToStartDatePicker subMsg ->
            let
                ( newDatePicker, dateEvent ) =
                    DatePicker.update
                        (startSettings model.endDate)
                        subMsg
                        model.startDatePicker

                newDate =
                    case dateEvent of
                        Picked changedDate ->
                            Just changedDate

                        _ ->
                            model.startDate
            in
            ( { model
                | startDate = newDate
                , startDatePicker = newDatePicker
              }
            , Cmd.none
            )

        ToEndDatePicker subMsg ->
            let
                ( newDatePicker, dateEvent ) =
                    DatePicker.update
                        (endSettings model.startDate)
                        subMsg
                        model.endDatePicker

                newDate =
                    case dateEvent of
                        Picked changedDate ->
                            Just changedDate

                        _ ->
                            model.endDate
            in
            ( { model
                | endDate = newDate
                , endDatePicker = newDatePicker
              }
            , Cmd.none
            )

        DeleteStartDate ->
            ( { model | startDate = Nothing }, Cmd.none )

        DeleteEndDate ->
            ( { model | endDate = Nothing }, Cmd.none )

        LoadExchange ->
            let
                { fixer_api_key } =
                    model.vars
            in
            ( { model | fetchingExchange = True }, fetchRates fixer_api_key )

        SetTimeZone zone ->
            ( { model | timeZone = zone }, Cmd.none )

        SetTimestamp time ->
            case model.exchange of
                Just exchange ->
                    let
                        updated =
                            { exchange | timestamp = time }
                    in
                    ( { model | exchange = Just updated }
                    , storeExchange (exchangeEncoder updated)
                    )

                Nothing ->
                    ( model, Cmd.none )

        RowClick currency ->
            ( model
            , Nav.pushUrl
                model.key
                (Builder.absolute [ "overview", currency ] [])
            )

        SortOverviewTable column ->
            ( { model
                | overviewTableSort =
                    updateTableSort column model.overviewTableSort
              }
            , Cmd.none
            )

        SortCurrencyTable column ->
            ( { model
                | currencyTableSort =
                    updateTableSort column model.currencyTableSort
              }
            , Cmd.none
            )


updateTableSort : String -> TableSort -> TableSort
updateTableSort name current =
    case current of
        Nothing ->
            Just ( name, DESC )

        Just ( currentName, sort ) ->
            if name == currentName then
                case sort of
                    DESC ->
                        Just ( name, ASC )

                    ASC ->
                        Nothing

            else
                Just ( name, DESC )


startSettings : Maybe Date -> DatePicker.Settings
startSettings endDate =
    let
        isDisabled =
            case endDate of
                Nothing ->
                    defaultSettings.isDisabled

                Just date ->
                    \d ->
                        Date.toRataDie d
                            > Date.toRataDie date
                            || defaultSettings.isDisabled d
    in
    { defaultSettings
        | placeholder = "Start date"
        , isDisabled = isDisabled
    }


endSettings : Maybe Date -> DatePicker.Settings
endSettings startDate =
    let
        isDisabled =
            case startDate of
                Nothing ->
                    defaultSettings.isDisabled

                Just date ->
                    \d ->
                        Date.toRataDie d
                            < Date.toRataDie date
                            || defaultSettings.isDisabled d
    in
    { defaultSettings
        | placeholder = "End date"
        , isDisabled = isDisabled
    }


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
            Http.get url exchangeDecoder
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
            , storeExpenses (expenseListEncoder (e :: model.expenses))
            )

        Nothing ->
            ( { model | error = Just ( InputError, "Invalid input" ) }
            , Cmd.none
            )
