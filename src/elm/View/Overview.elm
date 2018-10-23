module View.Overview exposing (view)

import Dict exposing (Dict)
import Expense exposing (Expense)
import Html
    exposing
        ( Html
        , section
        , table
        , tbody
        , td
        , text
        , th
        , thead
        , tr
        )
import Html.Attributes as H
import Messages exposing (Msg)
import Model exposing (Model)


aggregateTotal : Expense -> Dict String Float -> Dict String Float
aggregateTotal { currency, amount } acc =
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


currencyTotals : List Expense -> List ( String, Float )
currencyTotals expenses =
    expenses
        |> List.foldl aggregateTotal Dict.empty
        |> Dict.toList


viewTable : List ( String, Float ) -> Html Msg
viewTable data =
    table
        [ H.class "table is-fullwidth" ]
        [ thead []
            [ tr []
                [ th [] [ text "Currency" ]
                , th [] [ text "Amount" ]
                ]
            ]
        , tbody []
            (List.map
                (\( currency, amount ) ->
                    tr []
                        [ td [] [ text currency ]
                        , td [] [ text (String.fromFloat amount) ]
                        ]
                )
                data
            )
        ]


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ model.expenses
            |> currencyTotals
            |> viewTable
        ]
