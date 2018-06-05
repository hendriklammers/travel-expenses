module Main exposing (..)

import Model exposing (Model, Flags)
import Subscriptions exposing (subscriptions)
import Messages exposing (Msg(..))
import View.View exposing (view)
import Navigation exposing (Location)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags LocationChange
        { init = Model.init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        }
