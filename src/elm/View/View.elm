module View.View exposing (view)

import Browser
import Expense exposing (Currency)
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , h1
        , nav
        , span
        , text
        )
import Html.Attributes as H
import Html.Attributes.Aria as Aria
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (Error, MenuState(..), Model)
import Route exposing (Route(..), routeToString)
import View.Input as InputView
import View.Notfound as NotfoundView
import View.Overview as OverviewView


type alias MenuItem =
    { label : String
    , path : String
    , route : Route
    }


menuItems : List MenuItem
menuItems =
    [ MenuItem (routeToString Input) "" Input
    , MenuItem (routeToString Overview) "overview" Overview
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
                [ text (routeToString model.route) ]
            , viewBurger model
            ]
        , viewMenu model
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
            InputView.view model

        Overview ->
            OverviewView.view model Nothing

        CurrencyOverview code ->
            case findCurrency code model.currencies of
                Just currency ->
                    OverviewView.view model (Just currency)

                Nothing ->
                    NotfoundView.view model

        NotFound ->
            NotfoundView.view model


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
            [ H.class "container-fluid" ]
            [ viewError model.error
            , viewNavbar model
            , viewPage model
            ]
        ]
    }
