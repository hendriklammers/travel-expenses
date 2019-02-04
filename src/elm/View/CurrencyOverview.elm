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
import Messages exposing (Msg(..))
import Model exposing (Model)
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


viewTable : List ( String, Float ) -> Html Msg
viewTable rows =
    case rows of
        [] ->
            div [ H.class "notification" ]
                [ p [] [ text "No expenses found" ]
                ]

        _ ->
            table
                [ H.class "table is-fullwidth is-hoverable" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Category" ]
                        , th [] [ text "Amount" ]
                        ]
                    ]
                , tbody []
                    (List.map viewRow rows)
                ]


viewRow : ( String, Float ) -> Html Msg
viewRow ( category, amount ) =
    tr [ H.class "row" ]
        [ td [] [ text category ]
        , td [] [ text (Round.round 2 amount) ]
        ]


groupByCategory : List Expense -> List ( String, Float )
groupByCategory expenses =
    expenses
        |> List.foldl addAmount Dict.empty
        |> Dict.toList
        |> List.sortBy Tuple.second
        |> List.reverse



-- total =
--     List.foldl (\{ amount } acc -> acc + amount) 0 filtered


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
            |> viewTable
        ]
