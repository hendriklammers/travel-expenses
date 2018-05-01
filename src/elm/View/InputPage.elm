module View.InputPage exposing (view)

import Dict
import Model exposing (Model)
import Html
    exposing
        ( Html
        , a
        , text
        , div
        , input
        , section
        , form
        , button
        , fieldset
        , label
        , select
        , option
        )
import Messages exposing (Msg(..))
import Html.Attributes as H
import Html.Events exposing (onClick, onInput, onSubmit)
import Types
    exposing
        ( Category
        , Currency
        )


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
            if model.amount <= 0 then
                ""
            else
                toString model.amount
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


viewCurrencyOption : Currency -> Currency -> Html Msg
viewCurrencyOption active { code, name } =
    option
        [ H.value code
        , H.selected (active.code == code)
        ]
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
                    (List.map
                        (viewCurrencyOption currency)
                        (Dict.values currencies)
                    )
                ]
            ]
        ]


viewCategory : Category -> Category -> Html Msg
viewCategory active category =
    label
        [ H.class "radio" ]
        [ input
            [ H.type_ "radio"
            , H.name "category"
            , H.checked (active == category)
            , onClick (SelectCategory category)
            ]
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
