module Location exposing (Location(..), locationDecoder)

import Json.Decode as Decode exposing (Decoder)


type Location
    = Unavailable
    | NotSupported
    | TimeOut
    | PermissionDenied
    | Location LocationData


type alias LocationData =
    { accuracy : Float
    , latitude : Float
    , longitude : Float
    }


locationDecoder : Decoder Location
locationDecoder =
    Decode.oneOf
        [ Decode.map
            Location
            (Decode.field "data" locationDataDecoder)
        , Decode.field "error" Decode.string
            |> Decode.andThen locationErrorDecoder
        ]


locationErrorDecoder : String -> Decoder Location
locationErrorDecoder msg =
    case msg of
        "PERMISSION_DENIED" ->
            Decode.succeed PermissionDenied

        "POSITION_UNAVAILABLE" ->
            Decode.succeed Unavailable

        "TIMEOUT" ->
            Decode.succeed TimeOut

        _ ->
            Decode.succeed NotSupported


locationDataDecoder : Decoder LocationData
locationDataDecoder =
    Decode.map3 LocationData
        (Decode.field "accuracy" Decode.float)
        (Decode.field "latitude" Decode.float)
        (Decode.field "longitude" Decode.float)
