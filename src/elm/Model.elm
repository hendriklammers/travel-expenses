module Model exposing (Model, initial, update)

import Messages exposing (Msg(..))
import Types exposing (Category, Expense)


type alias Model =
    { amount : Float
    , category : Maybe Category
    , categories : List Category
    , expenses : List Expense
    }


categories : List Category
categories =
    [ { id = 0
      , name = "Food & Drink"
      }
    , { id = 1
      , name = "Accomodation"
      }
    , { id = 2
      , name = "Transportation"
      }
    , { id = 3
      , name = "Shopping"
      }
    , { id = 4
      , name = "Trips & Attractions"
      }
    , { id = 5
      , name = "Other"
      }
    ]


initial : Model
initial =
    { amount = 0
    , category = List.head categories
    , categories = categories
    , expenses = []
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

        AddExpense ->
            model ! []

        SelectCategory category ->
            { model | category = Just category } ! []
