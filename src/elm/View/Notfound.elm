module View.Notfound exposing (view)

import Html exposing (Html, section, text)
import Html.Attributes as H
import Messages exposing (Msg)
import Model exposing (Model)


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ text "Page not found" ]
