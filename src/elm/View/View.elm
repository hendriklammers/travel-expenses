module View.View exposing (view)

import Browser
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
import Route exposing (Route(..))
import View.Input as InputView
import View.Overview as OverviewView


type alias MenuItem =
    { label : String
    , path : String
    , route : Route
    }


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
                [ H.class "navbar-item is-capitalized" ]
                [ text "Travel expenses" ]
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


menuItems : List MenuItem
menuItems =
    [ MenuItem "Input" "" Input
    , MenuItem "Overview" "overview" Overview
    ]


viewMenuItem : Route -> MenuItem -> Html Msg
viewMenuItem active { label, route, path } =
    let
        activeClass =
            if active == route then
                " is-active"

            else
                ""

        href =
            "/" ++ path
    in
    a
        [ H.href href
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


viewPage : Model -> Html Msg
viewPage model =
    case model.route of
        Input ->
            InputView.view model

        Overview ->
            OverviewView.view model

        NotFound ->
            Debug.todo "add not found view"


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
