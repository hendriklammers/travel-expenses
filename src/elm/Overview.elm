module Overview exposing
    ( Row
    , sortByConversion
    , sortRows
    , view
    )

import CurrencyOverview as CurrencyOverview
import Date exposing (Date)
import DatePicker
import Dict exposing (Dict)
import Exchange exposing (Exchange)
import Expense exposing (Currency, Expense, filterDates)
import Html
    exposing
        ( Html
        , button
        , div
        , i
        , p
        , section
        , small
        , span
        , table
        , tbody
        , td
        , text
        , tfoot
        , th
        , thead
        , tr
        )
import Html.Attributes as H
import Html.Events exposing (onClick)
import Icons
import Model
    exposing
        ( Model
        , Msg(..)
        , Sort(..)
        , TableSort
        , endSettings
        , startSettings
        )
import Round
import Time
    exposing
        ( Month(..)
        , toDay
        , toHour
        , toMinute
        , toMonth
        , toYear
        )


addAmount : Expense -> Dict String Float -> Dict String Float
addAmount { currency, amount } acc =
    Dict.update
        currency.code
        (\value ->
            case value of
                Nothing ->
                    Just amount

                Just total ->
                    Just (total + amount)
        )
        acc


type alias Row =
    { currencyCode : String
    , amount : Float
    , conversion : Maybe Float
    }


currencyTotals : List Expense -> List ( String, Float )
currencyTotals expenses =
    expenses
        |> List.foldl addAmount Dict.empty
        |> Dict.toList


conversionTotals : Maybe Exchange -> List ( String, Float ) -> List Row
conversionTotals exchange =
    List.map
        (\( currency, amount ) ->
            let
                conversion =
                    exchange
                        |> Maybe.map .rates
                        |> Maybe.andThen (Dict.get currency)
                        |> Maybe.andThen (\rate -> Just (amount / rate))
            in
            Row currency amount conversion
        )


conversionString : Maybe Float -> String
conversionString conversion =
    case conversion of
        Nothing ->
            "-"

        Just value ->
            Round.round 2 value


sortByConversion : List Row -> List Row
sortByConversion rows =
    List.sortWith
        (\a b -> compareMaybe a.conversion b.conversion)
        rows


sortRows : TableSort -> List Row -> List Row
sortRows sort rows =
    case sort of
        Nothing ->
            rows

        Just ( column, sortType ) ->
            let
                sortList =
                    if column == "currency" then
                        List.sortBy .currencyCode

                    else if column == "amount" then
                        List.sortBy .amount

                    else if column == "conversion" then
                        sortByConversion

                    else
                        identity
            in
            rows
                |> sortList
                |> orderList sortType


orderList : Sort -> List a -> List a
orderList sort =
    case sort of
        DESC ->
            List.reverse

        _ ->
            identity


compareMaybe : Maybe comparable -> Maybe comparable -> Order
compareMaybe m1 m2 =
    case ( m1, m2 ) of
        ( Nothing, Nothing ) ->
            EQ

        ( Just _, Nothing ) ->
            LT

        ( Nothing, Just _ ) ->
            GT

        ( Just n1, Just n2 ) ->
            compare n1 n2


viewTable : Model -> Html Msg
viewTable model =
    let
        rows =
            model.expenses
                |> filterDates ( model.startDate, model.endDate )
                |> currencyTotals
                |> conversionTotals model.exchange
                |> sortRows model.overviewTableSort
    in
    case rows of
        [] ->
            div [ H.class "notification" ]
                [ p [] [ text "No expenses found" ]
                ]

        _ ->
            let
                total =
                    List.foldl
                        (.conversion >> Maybe.map2 (+))
                        (Just 0)
                        rows
            in
            table
                [ H.class "table overview-table is-fullwidth is-hoverable" ]
                [ thead []
                    [ tr []
                        [ th
                            [ H.class
                                (addSortClass "currency" model.overviewTableSort)
                            ]
                            [ span [ onClick (SortOverviewTable "currency") ]
                                [ text "Currency" ]
                            ]
                        , th
                            [ H.class
                                (addSortClass "amount" model.overviewTableSort)
                            ]
                            [ span [ onClick (SortOverviewTable "amount") ]
                                [ text "Amount" ]
                            ]
                        , th
                            [ H.class
                                (addSortClass "conversion" model.overviewTableSort)
                            ]
                            [ span [ onClick (SortOverviewTable "conversion") ]
                                [ text "Euro" ]
                            ]
                        ]
                    ]
                , tbody []
                    (List.map viewRow rows)
                , tfoot []
                    [ tr []
                        [ th [] [ text "Total" ]
                        , th [] []
                        , th [] [ text (conversionString total) ]
                        ]
                    ]
                ]


addSortClass : String -> TableSort -> String
addSortClass column sort =
    case sort of
        Nothing ->
            ""

        Just ( columnName, sortType ) ->
            if columnName == column then
                case sortType of
                    ASC ->
                        "sort--asc"

                    DESC ->
                        "sort--desc"

            else
                ""


viewRow : Row -> Html Msg
viewRow { currencyCode, amount, conversion } =
    tr [ onClick (RowClick (String.toLower currencyCode)), H.class "row" ]
        [ td []
            [ div
                [ H.class
                    ("currency-flag currency-flag-sm currency-flag-"
                        ++ String.toLower currencyCode
                    )
                ]
                []
            , text <| String.toUpper currencyCode
            ]
        , td [] [ text (Round.round 2 amount) ]
        , td [] [ text (conversionString conversion) ]
        ]


viewDelete : Msg -> String -> Maybe Date -> Html Msg
viewDelete msg name date =
    case date of
        Just _ ->
            button
                [ H.class ("elm-datepicker--delete delete-" ++ name)
                , onClick msg
                ]
                [ text "Delete" ]

        Nothing ->
            text ""


viewDatePicker : Model -> Html Msg
viewDatePicker model =
    div [ H.class "elm-datepicker" ]
        [ DatePicker.view
            model.startDate
            (startSettings model.endDate)
            model.startDatePicker
            |> Html.map ToStartDatePicker
        , viewDelete DeleteStartDate "start" model.startDate
        , div [ H.class "elm-datepicker--divider" ] [ text "-" ]
        , viewDelete DeleteEndDate "end" model.endDate
        , DatePicker.view
            model.endDate
            (endSettings model.startDate)
            model.endDatePicker
            |> Html.map ToEndDatePicker
        ]


toMonthString : Time.Month -> String
toMonthString month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"


posixToDateString : Time.Zone -> Time.Posix -> String
posixToDateString zone time =
    String.fromInt (toDay zone time)
        ++ " "
        ++ toMonthString (toMonth zone time)
        ++ " "
        ++ String.fromInt (toYear zone time)
        ++ " - "
        ++ (toHour zone time
                |> String.fromInt
                |> String.padLeft 2 '0'
           )
        ++ ":"
        ++ (toMinute zone time
                |> String.fromInt
                |> String.padLeft 2 '0'
           )


viewExchange : Model -> Html Msg
viewExchange { exchange, timeZone, fetchingExchange } =
    let
        loadingClass =
            if fetchingExchange then
                " is-loading"

            else
                ""
    in
    div [ H.class "exchange" ]
        (case exchange of
            Just { timestamp } ->
                [ small [ H.class ("exchange__text" ++ loadingClass) ]
                    [ text
                        ("Exchange rates: "
                            ++ posixToDateString timeZone timestamp
                        )
                    ]
                , button
                    [ H.class "button is-small exchange__update"
                    , onClick LoadExchange
                    ]
                    [ span
                        [ H.class "icon is-small" ]
                        [ Icons.sync ]
                    ]
                ]

            Nothing ->
                [ small [ H.class "exchange__text" ]
                    [ text "No exchange rates available" ]
                , button
                    [ H.class ("button is-small exchange__update" ++ loadingClass)
                    , onClick LoadExchange
                    ]
                    [ span
                        [ H.class "icon is-small" ]
                        [ Icons.sync ]
                    , span [] [ text "Update" ]
                    ]
                ]
        )


view : Model -> Maybe Currency -> Html Msg
view model currency =
    let
        viewData =
            case currency of
                Just c ->
                    CurrencyOverview.view model c

                Nothing ->
                    div []
                        [ viewTable model
                        , viewExchange model
                        ]
    in
    section
        [ H.class "section overview" ]
        [ viewDatePicker model
        , viewData
        ]
