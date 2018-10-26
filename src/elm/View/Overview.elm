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
        , tfoot
        , th
        , thead
        , tr
        )
import Html.Attributes as H
import Messages exposing (Msg)
import Model exposing (Model)


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


currencyTotals : List Expense -> List ( String, Float )
currencyTotals expenses =
    expenses
        |> List.foldl addAmount Dict.empty
        |> Dict.toList


viewTable : List ( String, Float ) -> Html Msg
viewTable data =
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
            (List.map viewRow data)
        , tfoot []
            [ tr []
                [ th [] [ text "Total" ]
                , th [] []
                , th [] [ text "todo" ]
                ]
            ]
        ]


viewRow : ( String, Float ) -> Html Msg
viewRow ( currency, amount ) =
    tr []
        [ td [] [ text currency ]
        , td [] [ text (String.fromFloat amount) ]
        , td [] [ text "todo" ]
        ]


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ model.expenses
            |> currencyTotals
            |> viewTable
        ]
