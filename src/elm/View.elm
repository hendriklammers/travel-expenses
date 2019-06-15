module View exposing (view)

import Browser
import Currencies
import Expense exposing (Currency)
import Html
    exposing
        ( Html
        , a
        , article
        , button
        , div
        , h1
        , i
        , nav
        , p
        , span
        , text
        )
import Html.Attributes as H
import Html.Attributes.Aria as Aria
import Html.Events exposing (onClick)
import Input
import Model
    exposing
        ( Error
        , MenuState(..)
        , Modal
        , Model
        , Msg(..)
        )
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
                , span []
                    [ text (routeToString model.route) ]
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


viewModal : Maybe Modal -> Html Msg
viewModal modal =
    case modal of
        Nothing ->
            text ""

        Just { action, color, label, message } ->
            div
                [ H.class "modal" ]
                [ div
                    [ H.class "modal-background"
                    , onClick CloseModal
                    ]
                    []
                , div [ H.class "modal-content" ]
                    [ article [ H.class ("message " ++ color) ]
                        [ div [ H.class "message-header" ]
                            [ span []
                                [ text "Confirmation" ]
                            , button
                                [ H.class "delete"
                                , onClick CloseModal
                                ]
                                [ text "Close" ]
                            ]
                        , div [ H.class "message-body has-text-grey-dark has-background-white" ]
                            [ p []
                                [ text message ]
                            , div [ H.class "buttons" ]
                                [ button
                                    [ H.class "button"
                                    , onClick CloseModal
                                    ]
                                    [ text "Cancel" ]
                                , button
                                    [ H.class ("button " ++ color)
                                    , onClick action
                                    ]
                                    [ text label ]
                                ]
                            ]
                        ]
                    ]
                ]


view : Model -> Browser.Document Msg
view model =
    { title = "Travel Expenses"
    , body =
        [ viewModal model.modal
        , if model.showCurrencies then
            Currencies.view model

          else
            text ""
        , div
            [ H.class ("app-container " ++ routeToClass model.route) ]
            [ viewError model.error
            , viewNavbar model
            , viewPage model
            ]
        ]
    }
