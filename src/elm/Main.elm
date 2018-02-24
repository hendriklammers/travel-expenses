module Main exposing (..)

import Model exposing (Model)
import Subscriptions exposing (subscriptions)
import Messages exposing (Msg(..))
import View.View exposing (view)
import Navigation exposing (Location)
import Routing exposing (parseLocation)


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model.initial (parseLocation location), Cmd.none )


main : Program Never Model Msg
main =
    Navigation.program LocationChange
        { init = init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        }
