module Types exposing (..)


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
    , currency : Maybe String
    , expenses : Maybe String
    }
