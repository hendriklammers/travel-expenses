module Notfound exposing (view)

import Html exposing (Html, h1, p, section, text)
import Html.Attributes as H
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ h1 [ H.class "subtitle is-4" ]
            [ text "Page not found" ]
        ]
