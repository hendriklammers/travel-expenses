module CurrencyOverview exposing (view)

import Dict exposing (Dict)
import Expense exposing (Currency, Expense, filterDates)
import Html
    exposing
        ( Html
        , button
        , div
        , header
        , p
        , section
        , span
        , table
        , tbody
        , td
        , text
        , th
        , thead
        , tr
        )
import Html.Attributes as H
import Html.Events exposing (onClick)
import Model exposing (Model, Msg(..), Sort(..), TableSort)
import Round


addAmount : Expense -> Dict String Float -> Dict String Float
addAmount { category, amount } acc =
    Dict.update
        category.name
        (\value ->
            case value of
                Nothing ->
                    Just amount

                Just total ->
                    Just (total + amount)
        )
        acc


type alias Row =
    ( String, Float )


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


viewTable : TableSort -> List Row -> Html Msg
viewTable sort rows =
    case rows of
        [] ->
            p [] [ text "No expenses found for this currency." ]

        _ ->
            table
                [ H.class "table is-fullwidth is-marginless" ]
                [ thead []
                    [ tr []
                        [ th
                            [ H.class
                                (addSortClass "category" sort)
                            ]
                            [ span [ onClick (SortCurrencyTable "category") ]
                                [ text "Category" ]
                            ]
                        , th
                            [ H.class
                                (addSortClass "amount" sort)
                            ]
                            [ span [ onClick (SortCurrencyTable "amount") ]
                                [ text "Amount" ]
                            ]
                        ]
                    ]
                , tbody []
                    (List.map viewRow rows)
                ]


viewRow : Row -> Html Msg
viewRow ( category, amount ) =
    tr [ H.class "row" ]
        [ td [] [ text category ]
        , td [] [ text (Round.round 2 amount) ]
        ]


groupByCategory : List Expense -> List Row
groupByCategory expenses =
    expenses
        |> List.foldl addAmount Dict.empty
        |> Dict.toList


sortRows : TableSort -> List Row -> List Row
sortRows sort rows =
    case sort of
        Nothing ->
            rows

        Just ( column, sortType ) ->
            let
                sortList =
                    if column == "category" then
                        List.sortBy Tuple.first

                    else if column == "amount" then
                        List.sortBy Tuple.second

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


view : Model -> Currency -> Html Msg
view model { code, name } =
    let
        filtered =
            model.expenses
                |> filterDates ( model.startDate, model.endDate )
                |> List.filter (\{ currency } -> currency.code == code)

        total =
            List.foldl (\{ amount } acc -> acc + amount) 0 filtered
    in
    section [ H.class "currency-overview" ]
        [ div [ H.class "message is-info is-marginless" ]
            [ header [ H.class "message-header header is-marginless" ]
                [ div
                    [ H.class
                        ("currency-flag currency-flag-lg currency-flag-"
                            ++ String.toLower code
                        )
                    ]
                    []
                , span []
                    [ text name ]
                , button
                    [ H.class "delete is-medium"
                    , onClick CloseCurrencyOverview
                    ]
                    [ text "Close" ]
                ]
            , div [ H.class "message-body is-radiusless" ]
                [ div [ H.class "total" ]
                    [ span
                        [ H.class "total__value is-size-3" ]
                        [ text (Round.round 2 total) ]
                    , span
                        [ H.class "total__label" ]
                        [ text (code ++ " in total") ]
                    ]
                , filtered
                    |> groupByCategory
                    |> sortRows model.currencyTableSort
                    |> viewTable model.currencyTableSort
                ]
            ]
        ]
