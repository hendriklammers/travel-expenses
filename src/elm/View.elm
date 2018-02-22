module View exposing (view)

import Html
    exposing
        ( Html
        , text
        , input
        , form
        , button
        , fieldset
        , label
        )
import Html.Attributes as H
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Types exposing (Category)
import Messages exposing (Msg(..))


viewCategory : Maybe Category -> Category -> Html Msg
viewCategory active category =
    let
        checked =
            case active of
                Just current ->
                    current == category

                Nothing ->
                    False
    in
        label []
            [ input
                [ H.type_ "radio"
                , H.name "category"
                , H.checked checked
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
        [ H.action ""
        , H.method "post"
        ]
        [ viewCategories model
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
            [ H.type_ "submit", onClick AddExpense ]
            [ text "Add" ]
        ]
