module Main exposing (..)

import Model exposing (Model)
import Subscriptions exposing (subscriptions)
import Messages exposing (Msg(..))
import View.View exposing (view)
import Navigation exposing (Location)
import Routing exposing (parseLocation)


init : Int -> Location -> ( Model, Cmd Msg )
init seed location =
    ( Model.initial seed (parseLocation location), Cmd.none )


main : Program Int Model Msg
main =
    Navigation.programWithFlags LocationChange
        { init = init
        , subscriptions = subscriptions
        , update = Model.update
        , view = view
        }
