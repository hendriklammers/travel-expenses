module Location exposing
    ( Location(..)
    , LocationData
    , locationDataDecoder
    , locationDataEncoder
    , locationDecoder
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Location
    = Unavailable
    | NotSupported
    | TimeOut
    | PermissionDenied
    | Location LocationData


type alias LocationData =
    ( Float, Float )


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
    Decode.map2 Tuple.pair
        (Decode.field "latitude" Decode.float)
        (Decode.field "longitude" Decode.float)


locationDataEncoder : LocationData -> Encode.Value
locationDataEncoder ( latitude, longitude ) =
    Encode.object
        [ ( "latitude", Encode.float latitude )
        , ( "longitude", Encode.float longitude )
        ]
