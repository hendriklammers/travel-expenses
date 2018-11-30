module View.Overview exposing (view)

import Date exposing (Date)
import DatePicker
import Dict exposing (Dict)
import Exchange exposing (Exchange)
import Expense exposing (Expense, filterDates)
import Html
    exposing
        ( Html
        , button
        , div
        , h1
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
import Messages exposing (Msg(..))
import Model exposing (Model, endSettings, startSettings)
import Round
import Time exposing (Month(..), toDay, toHour, toMinute, toMonth, toSecond, toYear, utc)


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
    { currency : String
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


viewTable : List Row -> Html Msg
viewTable rows =
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
                [ H.class "table is-fullwidth" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Currency" ]
                        , th [] [ text "Amount" ]
                        , th [] [ text "Euro" ]
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


viewRow : Row -> Html Msg
viewRow { currency, amount, conversion } =
    tr []
        [ td [] [ text currency ]
        , td [] [ text (Round.round 2 amount) ]
        , td [] [ text (conversionString conversion) ]
        ]


viewDelete : Messages.Msg -> String -> Maybe Date -> Html Msg
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
viewExchange { exchange, timeZone } =
    div []
        [ case exchange of
            Just { rates, timestamp } ->
                small []
                    [ text ("Last updated: " ++ posixToDateString timeZone timestamp) ]

            Nothing ->
                text "No conversion rates available"
        ]


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ viewDatePicker model
        , model.expenses
            |> filterDates ( model.startDate, model.endDate )
            |> currencyTotals
            |> conversionTotals model.exchange
            |> viewTable
        , viewExchange model
        , button
            [ H.class "button is-small", onClick LoadExchange ]
            [ text "Load exchange rates" ]
        ]
