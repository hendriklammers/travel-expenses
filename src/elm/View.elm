module View exposing (view)

import Html exposing (Html, text)
import Model exposing (Model)


view : Model -> Html msg
view model =
    text "Travel expenses app"
