module View exposing (view)

import Dict
import Html
    exposing
        ( Html
        , text
        , input
        , form
        , button
        , fieldset
        , label
        , select
        , option
        )
import Html.Attributes as H
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
    select
        [ onInput SelectCurrency ]
        (List.map (viewCurrencyOption currency) (Dict.values currencies))


viewCategory : Category -> Category -> Html Msg
viewCategory active category =
    label []
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
    fieldset []
        (List.map (viewCategory category) categories)


view : Model -> Html Msg
view model =
    form
        [ onSubmit AddExpense ]
        [ viewCurrency model
        , viewCategories model
        , input
            [ H.type_ "number"
            , H.placeholder "Amount"
            , H.id "amount-input"
            , H.class "amount-input"
            , H.step ".01"
            , onInput UpdateAmount
            ]
            []
        , button
            [ H.type_ "submit" ]
            [ text "Add" ]
        ]
