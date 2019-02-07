module Settings exposing (view)

import Html exposing (Html, section, text)
import Html.Attributes as H
import Model exposing (Model, Msg)


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ text "Settings" ]
