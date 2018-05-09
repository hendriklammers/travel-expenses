port module Ports exposing (..)

import Types exposing (Currency)


-- import Json.Encode exposing (Value)


port storeCurrency : Currency -> Cmd msg



-- port storeSession : Maybe String -> Cmd msg
--
-- port onSessionChange : (Value -> msg) -> Sub msg
