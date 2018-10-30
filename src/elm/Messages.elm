module Messages exposing (Msg(..))

import Browser
import DatePicker
import Exchange exposing (Exchange)
import Expense exposing (Category)
import Http
import Time exposing (Posix)
import Url


type Msg
    = UpdateAmount String
    | SelectCategory Category
    | SelectCurrency String
    | Submit
    | AddExpense Posix
    | CloseError
    | ToggleMenu
    | NewRates (Result Http.Error Exchange)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ToStartDatePicker DatePicker.Msg
    | ToEndDatePicker DatePicker.Msg
    | LoadExchange
