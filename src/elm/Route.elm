module Route exposing (Route(..), routeToString, toRoute)

import Url
import Url.Parser as Parser exposing ((</>))


type Route
    = Input
    | Overview
    | CurrencyOverview String
    | NotFound


routeToString : Route -> String
routeToString route =
    case route of
        Input ->
            "Input"

        Overview ->
            "Overview"

        CurrencyOverview cur ->
            "Overview " ++ String.toUpper cur

        NotFound ->
            "Page not found"


routeParser : Parser.Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Input Parser.top
        , Parser.map Overview (Parser.s "overview")
        , Parser.map CurrencyOverview (Parser.s "overview" </> Parser.string)
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)
