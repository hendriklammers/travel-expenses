module View exposing (view)

import Browser
import Expense exposing (Currency)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , h1
        , i
        , nav
        , span
        , text
        )
import Html.Attributes as H
import Html.Attributes.Aria as Aria
import Html.Events exposing (onClick)
import Input
import Model exposing (Error, MenuState(..), Model, Msg(..))
import Notfound
import Overview
import Route
    exposing
        ( Route(..)
        , routeIcon
        , routeToClass
        , routeToString
        )
import Settings


type alias MenuItem =
    { label : String
    , path : String
    , route : Route
    }


menuItems : List MenuItem
menuItems =
    [ MenuItem (routeToString Input) "" Input
    , MenuItem (routeToString Overview) "overview" Overview
    , MenuItem (routeToString Settings) "settings" Settings
    ]


viewNavbar : Model -> Html Msg
viewNavbar model =
    nav
        [ H.class "navbar is-dark"
        , Aria.role "navigation"
        , Aria.ariaLabel "main navigation"
        ]
        [ div
            [ H.class "navbar-brand" ]
            [ h1
                [ H.class "navbar-item" ]
                [ navbarIcon model.route
                , text (routeToString model.route)
                ]
            , viewBurger model
            ]
        , viewMenu model
        ]


navbarIcon : Route -> Html Msg
navbarIcon route =
    span
        [ H.class "icon" ]
        [ i [ H.class ("fas fa-" ++ routeIcon route) ] []
        ]


viewBurger : Model -> Html Msg
viewBurger { menu } =
    div
        [ H.class ("navbar-burger" ++ menuClass menu)
        , onClick ToggleMenu
        ]
        (List.map (\_ -> span [] []) (List.range 0 2))


menuClass : MenuState -> String
menuClass state =
    case state of
        MenuOpen ->
            " is-active"

        MenuClosed ->
            ""


viewMenuItem : Route -> MenuItem -> Html Msg
viewMenuItem active { label, route, path } =
    let
        activeClass =
            if active == route then
                " is-active"

            else
                ""
    in
    a
        [ H.href ("/" ++ path)
        , H.class ("navbar-item is-capitalized" ++ activeClass)
        ]
        [ text label ]


viewMenu : Model -> Html Msg
viewMenu { menu, route } =
    let
        active =
            route
    in
    div
        [ H.class ("navbar-menu" ++ menuClass menu) ]
        [ div
            [ H.class "navbar-end" ]
            (List.map (viewMenuItem active) menuItems)
        ]


findCurrency : String -> List Currency -> Maybe Currency
findCurrency code list =
    case list of
        [] ->
            Nothing

        x :: xs ->
            if String.toLower code == String.toLower x.code then
                Just x

            else
                findCurrency code xs


viewPage : Model -> Html Msg
viewPage model =
    case model.route of
        Input ->
            Input.view model

        Overview ->
            Overview.view model Nothing

        CurrencyOverview code ->
            case findCurrency code model.currencies of
                Just currency ->
                    Overview.view model (Just currency)

                Nothing ->
                    Notfound.view model

        Settings ->
            Settings.view model

        NotFound ->
            Notfound.view model


viewError : Maybe Error -> Html Msg
viewError error =
    case error of
        Just ( _, message ) ->
            div
                [ H.class "notification is-danger is-marginless is-radiusless" ]
                [ button
                    [ H.class "delete"
                    , onClick CloseError
                    ]
                    []
                , text message
                ]

        Nothing ->
            text ""


view : Model -> Browser.Document Msg
view model =
    { title = "Travel Expenses"
    , body =
        [ div
            [ H.class ("container-fluid " ++ routeToClass model.route) ]
            [ viewError model.error
            , viewNavbar model
            , viewPage model
            ]
        ]
    }
