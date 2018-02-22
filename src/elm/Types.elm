module Types exposing (..)

import Date exposing (Date)


type alias Category =
    { id : Int
    , name : String
    }


type alias Currency =
    { code : String
    , name : String
    }


type alias Expense =
    { category : Category
    , amount : Float
    , currency : String
    , date : Date

    -- , id : Int
    -- , location : Location
    }
