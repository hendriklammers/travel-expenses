module Route exposing (Route(..), routeToClass, routeToString, toRoute)

import Url
import Url.Parser as Parser exposing ((</>))


type Route
    = Input
    | Overview
    | CurrencyOverview String
    | Settings
    | NotFound


routeToString : Route -> String
routeToString route =
    case route of
        Input ->
            "Input"

        Overview ->
            "Overview"

        CurrencyOverview cur ->
            -- "Overview" ++ String.toUpper cur
            "Overview"

        Settings ->
            "Settings"

        NotFound ->
            "Not found"


routeToClass : Route -> String
routeToClass route =
    route
        |> routeToString
        |> String.toLower
        |> String.replace " " ""
        |> (++) "route-"


routeParser : Parser.Parser (Route -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Input Parser.top
        , Parser.map Overview (Parser.s "overview")
        , Parser.map CurrencyOverview (Parser.s "overview" </> Parser.string)
        , Parser.map Settings (Parser.s "settings")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)
