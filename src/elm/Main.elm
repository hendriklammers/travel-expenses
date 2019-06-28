module Main exposing (main)

import Browser exposing (application)
import Json.Decode as Decode
import Location exposing (locationDecoder)
import Model exposing (Flags, Model, Msg(..))
import Ports exposing (updateLocation)
import View exposing (view)


subscriptions : Model -> Sub Msg
subscriptions _ =
    updateLocation (Decode.decodeString locationDecoder >> ReceiveLocation)


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
