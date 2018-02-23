module Model exposing (Model, initial, update)

import Task
import Date
import Dict exposing (Dict)
import Messages exposing (Msg(..))
import Types exposing (Category, Expense, Currency)


type alias Model =
    { amount : Float
    , category : Category
    , categories : List Category
    , currency : Currency
    , currencies : Dict String Currency
    , expenses : List Expense
    , error : Maybe String
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



-- Only the ones I currently use for now...


currencies : Dict String Currency
currencies =
    Dict.fromList
        (List.map
            (\c -> ( c.code, c ))
            [ { code = "USD"
              , name = "United States Dollar"
              }
            , { code = "EUR"
              , name = "Euro"
              }
            , { code = "THB"
              , name = "Thai Baht"
              }
            , { code = "VND"
              , name = "Vietnamese Dong"
              }
            , { code = "KHR"
              , name = "Cambodian Riel"
              }
            ]
        )


initial : Model
initial =
    { amount = 0
    , category =
        { id = 0
        , name = "Food & Drink"
        }
    , categories = categories
    , currency =
        { code = "USD"
        , name = "United States Dollar"
        }
    , currencies = currencies
    , expenses = []
    , error = Nothing
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

        Submit ->
            if model.amount <= 0 then
                { model
                    | error = Just "Please enter the amount of money spent"
                }
                    ! []
            else
                ( model, Task.perform ReceiveDate Date.now )

        ReceiveDate date ->
            let
                expense =
                    { category = model.category
                    , amount = model.amount
                    , currency = model.currency
                    , date = date
                    }
            in
                { model | expenses = expense :: model.expenses } ! []

        SelectCategory category ->
            { model | category = category } ! []

        SelectCurrency selected ->
            case Dict.get selected model.currencies of
                Just currency ->
                    { model | currency = currency } ! []

                Nothing ->
                    model ! []

        CloseError ->
            { model | error = Nothing } ! []
