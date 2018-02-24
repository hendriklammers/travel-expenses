module View.OverviewPage exposing (view)

import Html exposing (Html, section, text)
import Html.Attributes as H
import Model exposing (Model)
import Messages exposing (Msg)


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ text "Overview" ]
