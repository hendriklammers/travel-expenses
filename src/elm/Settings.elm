module Settings exposing (view)

import Html
    exposing
        ( Html
        , button
        , div
        , h2
        , i
        , section
        , span
        , text
        )
import Html.Attributes as H
import Html.Events exposing (onClick)
import Model exposing (Modal, Model, Msg(..))


deleteModal : Msg
deleteModal =
    ShowModal
        { action = DeleteData
        , color = "is-danger"
        , label = "Delete"
        , message = "Are you sure you want to delete all data?"
        }


view : Model -> Html Msg
view model =
    section
        [ H.class "section" ]
        [ h2 [ H.class "title is-6" ]
            [ text "Manage application data" ]
        , div [ H.class "buttons" ]
            [ button
                [ H.class "button is-fullwidth", onClick ExportData ]
                [ span
                    [ H.class "icon" ]
                    [ i [ H.class "fas fa-download" ] [] ]
                , span [] [ text "Export data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick ImportData ]
                [ span
                    [ H.class "icon" ]
                    [ i [ H.class "fas fa-file-upload" ] [] ]
                , span [] [ text "Import data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick deleteModal ]
                [ span
                    [ H.class "icon" ]
                    [ i [ H.class "fas fa-trash" ] [] ]
                , span [] [ text "Delete data" ]
                ]
            ]
        ]
