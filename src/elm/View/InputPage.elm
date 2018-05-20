module View.InputPage exposing (view)

import Model exposing (Model, ErrorType(..))
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
import Expense exposing (Category, Currency)


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

        errorClass =
            case model.error of
                Just ( err, msg ) ->
                    if err == AmountError then
                        " is-danger"
                    else
                        ""

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
                    , H.class ("input amount-input" ++ errorClass)
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
        ([ (H.value code) ]
            ++ case active of
                Just c ->
                    [ H.selected (c.code == code) ]

                Nothing ->
                    []
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
                    (List.map
                        (viewCurrencyOption currency)
                        currencies
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
                ++ case active of
                    Just c ->
                        [ H.checked (c == category) ]

                    Nothing ->
                        []
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
