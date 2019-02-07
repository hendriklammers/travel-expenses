module Main exposing (main)

import Browser exposing (Document)
import Model exposing (Flags, Model, Msg(..))
import View exposing (view)


subscriptions : Model -> Sub Msg
subscriptions =
    always Sub.none


main : Program Flags Model Msg
main =
    Browser.application
        { init = Model.init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
