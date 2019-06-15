module Input exposing (view)

import Dict
import Expense exposing (Category, Currency)
import Html
    exposing
        ( Html
        , button
        , div
        , form
        , input
        , label
        , option
        , section
        , select
        , text
        )
import Html.Attributes as H
import Html.Events exposing (onClick, onInput, onSubmit)
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ form
            [ onSubmit Submit
            , H.method "post"
            , H.action ""
            ]
            [ viewAmount model
            , viewCurrency model
            , viewCategories model
            , viewSubmitButton
            ]
        ]


viewAmount : Model -> Html Msg
viewAmount model =
    let
        value =
            case model.amount of
                Just amount ->
                    String.fromFloat amount

                Nothing ->
                    ""
    in
    div [ H.class "field" ]
        [ label
            [ H.class "label" ]
            [ text "Amount" ]
        , div
            [ H.class "control" ]
            [ input
                [ H.type_ "number"
                , H.placeholder "0.00"
                , H.id "amount-input"
                , H.class "input amount-input"
                , H.step ".01"
                , H.value value
                , onInput UpdateAmount
                ]
                []
            ]
        ]


viewCurrencyOption : Maybe Currency -> Currency -> Html Msg
viewCurrencyOption active { code, name } =
    option
        (H.value code
            :: (case active of
                    Just c ->
                        [ H.selected (c.code == code) ]

                    Nothing ->
                        []
               )
        )
        [ text (code ++ " - " ++ name) ]


viewCurrency : Model -> Html Msg
viewCurrency { currencies, currency } =
    div
        [ H.class "field" ]
        [ label
            [ H.class "label" ]
            [ text "Currency" ]
        , div
            [ H.class "control is-expanded" ]
            [ div
                [ H.class "select is-fullwidth" ]
                [ select
                    [ onInput SelectCurrency ]
                    (currencies
                        |> Dict.toList
                        |> List.filter (Tuple.second >> .active)
                        |> List.map (Tuple.second >> viewCurrencyOption currency)
                    )
                ]
            ]
        ]


viewCategory : Maybe Category -> Category -> Html Msg
viewCategory active category =
    label
        [ H.class "radio" ]
        [ input
            ([ H.type_ "radio"
             , H.name "category"
             , onClick (SelectCategory category)
             ]
                ++ (case active of
                        Just c ->
                            [ H.checked (c == category) ]

                        Nothing ->
                            []
                   )
            )
            []
        , text category.name
        ]


viewCategories : Model -> Html Msg
viewCategories { category, categories } =
    div [ H.class "field categories" ]
        [ label
            [ H.class "label" ]
            [ text "Category" ]
        , div
            [ H.class "control" ]
            (List.map (viewCategory category) categories)
        ]


viewSubmitButton : Html Msg
viewSubmitButton =
    div [ H.class "field" ]
        [ div
            [ H.class "control" ]
            [ button
                [ H.type_ "submit"
                , H.class "button is-primary is-medium is-fullwidth"
                ]
                [ text "Add" ]
            ]
        ]
