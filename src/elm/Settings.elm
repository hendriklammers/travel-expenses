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
import Icons
import Model exposing (Model, Msg(..))


showDeleteModal : Msg
showDeleteModal =
    ShowModal
        { action = DeleteData
        , color = "is-danger"
        , label = "Delete"
        , message = "Are you sure you want to delete all data?"
        }


view : Model -> Html Msg
view _ =
    section
        [ H.class "section" ]
        [ h2 [ H.class "title is-6" ]
            [ text "Preferences" ]
        , div [ H.class "buttons" ]
            [ button
                [ H.class "button is-fullwidth"
                , onClick OpenCurrencies
                ]
                [ Icons.euroSign
                , span [] [ text "Active currencies" ]
                ]
            ]
        , h2 [ H.class "title is-6" ]
            [ text "Manage application data" ]
        , div [ H.class "buttons" ]
            [ button
                [ H.class "button is-fullwidth", onClick ExportData ]
                [ Icons.download
                , span [] [ text "Export data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick ImportData ]
                [ Icons.fileUpload
                , span [] [ text "Import data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick showDeleteModal ]
                [ Icons.trash
                , span [] [ text "Delete data" ]
                ]
            ]
        ]
