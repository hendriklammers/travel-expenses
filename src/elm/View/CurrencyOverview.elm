module View.CurrencyOverview exposing (view)

import Expense exposing (Currency)
import Html exposing (Html, text)
import Messages exposing (Msg(..))
import Model exposing (Model)


view : Model -> Currency -> Html Msg
view model { name } =
    text name
