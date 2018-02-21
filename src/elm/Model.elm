module Model exposing (Model, initial, update)

import Messages exposing (Msg(..))


type alias Model =
    { amount : Float
    , category : Category
    , categories : List Category
    }


type alias Category =
    { id : Int
    , name : String
    }


initial : Model
initial =
    { amount = 0
    , category =
        { id = 0
        , name = "Other"
        }
    , categories = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateAmount value ->
            let
                amount =
                    case String.toFloat value of
                        Ok result ->
                            result

                        Err _ ->
                            0
            in
                { model | amount = amount } ! []

        AddAmount ->
            model ! []
