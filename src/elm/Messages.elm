module Messages exposing (Msg(..))

import Types exposing (Category)


type Msg
    = AddExpense
    | UpdateAmount String
    | SelectCategory Category
    | SelectCurrency String
