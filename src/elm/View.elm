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


viewCategory : Category -> Html Msg
viewCategory { id, name } =
    label []
        [ input
            [ H.type_ "radio"
            , H.name "category"
            , onClick NoOp
            ]
            []
        , text name
        ]


viewCategories : List Category -> Html Msg
viewCategories categories =
    fieldset []
        (List.map viewCategory categories)


view : Model -> Html Msg
view model =
    form
        [ H.action ""
        , H.method "post"
        ]
        [ viewCategories model.categories
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
            [ H.type_ "submit", onClick AddAmount ]
            [ text "Add" ]
        ]
