module Route exposing (Route(..), toRoute)

import Url
import Url.Parser as Parser


type Route
    = Input
    | Overview
    | NotFound


routeParser : Parser.Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Input Parser.top
        , Parser.map Overview (Parser.s "overview")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)
