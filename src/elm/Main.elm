module Main exposing (main)

import Browser exposing (application)
import Model exposing (Flags, Model, Msg(..))
import Ports exposing (updateLocation)
import View exposing (view)


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateLocation (\location -> ReceiveLocation location)


main : Program Flags Model Msg
main =
    application
        { init = Model.init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
