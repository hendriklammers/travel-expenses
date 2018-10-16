module Main exposing (main)

import Browser exposing (Document)
import Messages exposing (Msg(..))
import Model exposing (Flags, Model)
import Subscriptions exposing (subscriptions)
import View.View exposing (view)


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
