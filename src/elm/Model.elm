module Model exposing (Model, initial, update)

import Dict exposing (Dict)
import Messages exposing (Msg(..))
import Types exposing (Category, Expense, Currency)


type alias Model =
    { amount : Float
    , category : Maybe Category
    , categories : List Category
    , currency : Maybe Currency
    , currencies : Dict String Currency
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
    , category = List.head categories
    , categories = categories
    , currency = Dict.get "USD" currencies
    , currencies = currencies
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

        SelectCurrency selected ->
            let
                currency =
                    Dict.get selected model.currencies
            in
                { model | currency = currency } ! []
