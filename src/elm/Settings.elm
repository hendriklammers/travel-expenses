module Settings exposing (view)

import Html exposing (Html, button, i, section, span, text)
import Html.Attributes as H
import Html.Events exposing (onClick)
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ button
            [ H.class "button", onClick ExportData ]
            [ span
                [ H.class "icon" ]
                [ i [ H.class "fas fa-file-export" ] [] ]
            , span [] [ text "Export data" ]
            ]
        ]
