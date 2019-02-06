module View.CurrencyOverview exposing (view)

import Date exposing (Date)
import DatePicker
import Dict exposing (Dict)
import Expense exposing (Currency, Expense, filterDates)
import Html
    exposing
        ( Html
        , div
        , h2
        , p
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
                        [ th []
                            [ span [ onClick (SortCurrencyTable "category") ]
                                [ text "Category" ]
                            ]
                        , th []
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



-- total =
--     List.foldl (\{ amount } acc -> acc + amount) 0 filtered


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
        ASC ->
            List.reverse

        _ ->
            identity


view : Model -> Currency -> Html Msg
view model currency =
    div []
        [ h2 [ H.class "title is-5" ]
            [ text currency.name ]
        , model.expenses
            -- TODO: Combine date and category filter
            |> filterDates ( model.startDate, model.endDate )
            |> List.filter (\e -> e.currency == currency)
            |> groupByCategory
            |> sortRows model.currencyTableSort
            |> viewTable
        ]
