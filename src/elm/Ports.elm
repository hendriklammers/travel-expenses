port module Ports exposing (..)

import Types exposing (Currency, Expense)


port storeCurrency : Currency -> Cmd msg


port storeExpenses : String -> Cmd msg
