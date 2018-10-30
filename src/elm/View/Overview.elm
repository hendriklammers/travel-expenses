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
import Time


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


type Conversion
    = Converted Float
    | Unavailable


type alias Row =
    { currency : String
    , amount : Float
    , conversion : Float
    }


currencyTotals : List Expense -> List ( String, Float )
currencyTotals expenses =
    expenses
        |> List.foldl addAmount Dict.empty
        |> Dict.toList


conversionTotals : Maybe Exchange -> List ( String, Float ) -> List Row
conversionTotals exchange xs =
    List.map
        (\( currency, amount ) ->
            let
                converted =
                    case exchange of
                        Nothing ->
                            666

                        Just ex ->
                            case Dict.get currency ex.rates of
                                Nothing ->
                                    666

                                Just rate ->
                                    amount / rate
            in
            Row currency amount converted
        )
        xs


viewTable : List Row -> Html Msg
viewTable rows =
    case rows of
        [] ->
            div [ H.class "notification" ]
                [ p [] [ text "No expenses found" ]
                ]

        _ ->
            table
                [ H.class "table is-fullwidth" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Currency" ]
                        , th [] [ text "Amount" ]
                        , th [] [ text "Converted" ]
                        ]
                    ]
                , tbody []
                    (List.map viewRow rows)
                , tfoot []
                    [ tr []
                        [ th [] [ text "Total" ]
                        , th [] []
                        , th [] [ text "todo" ]
                        ]
                    ]
                ]


viewRow : Row -> Html Msg
viewRow { currency, amount, conversion } =
    tr []
        [ td [] [ text currency ]
        , td [] [ text (String.fromFloat amount) ]
        , td [] [ text (String.fromFloat conversion) ]
        ]


viewDatePicker : Model -> Html Msg
viewDatePicker model =
    div [ H.class "elm-datepicker" ]
        [ DatePicker.view
            model.startDate
            (startSettings model.endDate)
            model.startDatePicker
            |> Html.map ToStartDatePicker
        , span [ H.class "elm-datepicker--divider" ] [ text "-" ]
        , DatePicker.view
            model.endDate
            (endSettings model.startDate)
            model.endDatePicker
            |> Html.map ToEndDatePicker
        ]


viewRange : Maybe Date -> Maybe Date -> Html Msg
viewRange start end =
    case ( start, end ) of
        ( Nothing, Nothing ) ->
            h1 [] [ text "Pick dates" ]

        ( Just s, Nothing ) ->
            h1 [] [ text <| formatDate s ++ " – Pick end date" ]

        ( Nothing, Just e ) ->
            h1 [] [ text <| "Pick start date – " ++ formatDate e ]

        ( Just s, Just e ) ->
            h1 [] [ text <| formatDate s ++ " – " ++ formatDate e ]


formatDate : Date -> String
formatDate d =
    Date.format "MMM dd, yyyy" d


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ viewDatePicker model
        , button
            [ H.class "button is-small", onClick LoadExchange ]
            [ text "Load exchange rates" ]
        , model.expenses
            |> filterDates ( model.startDate, model.endDate )
            |> currencyTotals
            |> conversionTotals model.exchange
            |> viewTable
        ]
