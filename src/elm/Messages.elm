module Messages exposing (Msg(..))

import Types exposing (Category)


type Msg
    = AddAmount
    | NoOp
    | UpdateAmount String
    | SelectCategory Category
