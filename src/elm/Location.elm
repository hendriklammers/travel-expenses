module Location exposing (Location(..), LocationData)


type Location
    = Unavailable
    | NotSupported
    | Location LocationData


type alias LocationData =
    { accuracy : Float
    , latitude : Float
    , longitude : Float
    }
