module View exposing (view)

import Dict
import Html
    exposing
        ( Html
        , a
        , article
        , text
        , div
        , input
        , section
        , nav
        , form
        , button
        , fieldset
        , label
        , select
        , option
        )
import Html.Attributes as H
import Html.Attributes.Aria as Aria
import Html.Events exposing (onClick, onInput, onSubmit)
import Model exposing (Model)
import Types exposing (Category, Currency)
import Messages exposing (Msg(..))


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


viewAmount : Model -> Html Msg
viewAmount model =
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
                , onInput UpdateAmount
                ]
                []
            ]
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


viewNavbar : Html Msg
viewNavbar =
    nav
        [ H.class "navbar is-dark has-shadow"
        , Aria.role "navigation"
        , Aria.ariaLabel "main navigation"
        ]
        [ div
            [ H.class "navbar-brand" ]
            [ a
                [ H.href "/"
                , H.class "navbar-item is-capitalized"
                ]
                [ text "Travel expenses" ]
            ]
        ]


viewForm : Model -> Html Msg
viewForm model =
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


viewError : Maybe String -> Html Msg
viewError message =
    case message of
        Just error ->
            div
                [ H.class "notification is-danger is-marginless is-radiusless" ]
                [ button
                    [ H.class "delete"
                    , onClick CloseError
                    ]
                    []
                , text error
                ]

        Nothing ->
            text ""


view : Model -> Html Msg
view model =
    div
        [ H.class "container-fluid" ]
        [ viewError model.error
        , viewNavbar
        , viewForm model
        ]
