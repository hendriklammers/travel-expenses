module Routing exposing (Page(..), parseLocation)

import Navigation exposing (Location)


type Page
    = InputPage
    | OverviewPage


parseLocation : Location -> Page
parseLocation { hash } =
    case hash of
        "#input" ->
            InputPage

        "#overview" ->
            OverviewPage

        _ ->
            InputPage
