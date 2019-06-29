port module Ports exposing
    ( storeActiveCurrencies
    , storeCurrency
    , storeExchange
    , storeExpenses
    , updateLocation
    )


port storeCurrency : String -> Cmd msg


port storeExpenses : String -> Cmd msg


port storeExchange : String -> Cmd msg


port storeActiveCurrencies : String -> Cmd msg


port updateLocation : (String -> msg) -> Sub msg
