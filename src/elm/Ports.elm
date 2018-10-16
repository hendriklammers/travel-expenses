port module Ports exposing (storeCurrency, storeExchange, storeExpenses)


port storeCurrency : String -> Cmd msg


port storeExpenses : String -> Cmd msg


port storeExchange : String -> Cmd msg
