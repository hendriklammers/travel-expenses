module View exposing (view)

import Html exposing (Html, text, input, form, button)
import Html.Attributes as H
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    form
        [ H.action ""
        , H.method "post"
        ]
        [ input
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
