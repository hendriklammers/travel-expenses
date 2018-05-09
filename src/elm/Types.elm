module Types exposing (..)

import Date exposing (Date)
import Uuid


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
    , currency : Currency
    , date : Date
    , id : Uuid.Uuid

    -- , location : Location
    }


type MenuState
    = MenuOpen
    | MenuClosed


type ErrorType
    = CurrencyError
    | AmountError


type alias Error =
    ( ErrorType, String )


type alias MenuItem =
    ( String, Page )


type Page
    = InputPage
    | OverviewPage


type alias Flags =
    { seed : Int
    , currency : Maybe Currency
    }
