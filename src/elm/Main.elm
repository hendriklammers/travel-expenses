module Main exposing (..)

import Model exposing (Model, Flags)
import Subscriptions exposing (subscriptions)
import Messages exposing (Msg(..))
import View.View exposing (view)
import Navigation exposing (Location)
import Routing exposing (parseLocation)


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( Model.initial flags (parseLocation location), Cmd.none )


main : Program Flags Model Msg
main =
    Navigation.programWithFlags LocationChange
        { init = init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        }
