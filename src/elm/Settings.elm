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
                [ span
                    [ H.class "icon is-small" ]
                    [ Icons.euroSign ]
                , span [] [ text "Active currencies" ]
                ]
            ]
        , h2 [ H.class "title is-6" ]
            [ text "Manage application data" ]
        , div [ H.class "buttons" ]
            [ button
                [ H.class "button is-fullwidth", onClick ExportData ]
                [ span
                    [ H.class "icon" ]
                    [ Icons.download ]
                , span [] [ text "Export data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick ImportData ]
                [ span
                    [ H.class "icon" ]
                    [ Icons.fileUpload ]
                , span [] [ text "Import data" ]
                ]
            , button
                [ H.class "button is-fullwidth", onClick showDeleteModal ]
                [ span
                    [ H.class "icon" ]
                    [ Icons.trash ]
                , span [] [ text "Delete data" ]
                ]
            ]
        ]
