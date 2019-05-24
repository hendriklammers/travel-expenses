import './scss/main.scss'
import { Elm } from './elm/Main'

// Flags should be either a string value or null
const flag = (val: string | undefined) =>
  typeof val === 'undefined' ? null : val

const flags = {
  seed: Math.floor(Math.random() * 0x0fffffff),
  currency: flag(localStorage.currency),
  expenses: flag(localStorage.expenses),
  exchange: flag(localStorage.exchange),
}
const app = Elm.Main.init({ flags })

app.ports.storeCurrency.subscribe(currency => {
  localStorage.currency = currency
})

app.ports.storeExpenses.subscribe(expenses => {
  localStorage.expenses = expenses
})

app.ports.storeExchange.subscribe(exchange => {
  localStorage.exchange = exchange
})