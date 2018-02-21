module Main exposing (..)

import Model exposing (Model)
import Subscriptions exposing (subscriptions)
import Messages exposing (Msg(..))
import View exposing (view)
import Html exposing (program)


main : Program Never Model Msg
main =
    program
        { init = ( Model.initial, Cmd.none )
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        }
