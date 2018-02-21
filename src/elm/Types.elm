module Types exposing (..)

import Date exposing (Date)


type alias Category =
    { id : Int
    , name : String
    }


type alias Expense =
    { category : Category
    , amount : Float
    , currency : String
    , id : Int
    , date : Date
    }
