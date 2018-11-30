module Messages exposing (Msg(..))

import Browser
import DatePicker
import Exchange exposing (Exchange)
import Expense exposing (Category)
import Http
import Time
import Url


type Msg
    = UpdateAmount String
    | SelectCategory Category
    | SelectCurrency String
    | Submit
    | AddExpense Time.Posix
    | CloseError
    | ToggleMenu
    | NewRates (Result Http.Error Exchange)
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | ToStartDatePicker DatePicker.Msg
    | ToEndDatePicker DatePicker.Msg
    | LoadExchange
    | DeleteStartDate
    | DeleteEndDate
    | SetTimeZone Time.Zone
    | SetTimestamp Time.Posix
