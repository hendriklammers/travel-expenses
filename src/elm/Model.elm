module Model exposing (Model, initial, update)

import Messages exposing (Msg(..))


type alias Model =
    { amount : Float
    }


initial : Model
initial =
    { amount = 0
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []
