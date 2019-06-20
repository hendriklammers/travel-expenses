port module Ports exposing
    ( storeActiveCurrencies
    , storeCurrency
    , storeExchange
    , storeExpenses
    , updateLocation
    )

import Location exposing (LocationData)


port storeCurrency : String -> Cmd msg


port storeExpenses : String -> Cmd msg


port storeExchange : String -> Cmd msg


port storeActiveCurrencies : String -> Cmd msg


port updateLocation : (LocationData -> msg) -> Sub msg
