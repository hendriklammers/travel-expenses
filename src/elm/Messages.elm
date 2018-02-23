module Messages exposing (Msg(..))

import Date exposing (Date)
import Types exposing (Category)


type Msg
    = UpdateAmount String
    | SelectCategory Category
    | SelectCurrency String
    | Submit
    | ReceiveDate Date
    | CloseError
