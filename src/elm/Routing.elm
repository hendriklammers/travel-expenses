module Routing exposing (parseLocation)

import Types exposing (Page(..))
import Navigation exposing (Location)


parseLocation : Location -> Page
parseLocation { hash } =
    case hash of
        "#input" ->
            InputPage

        "#overview" ->
            OverviewPage

        _ ->
            InputPage
