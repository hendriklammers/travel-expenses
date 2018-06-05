import './scss/main.scss'
import Elm from './elm/Main'

// Used to generate uuid's inside the Elm program
const container = document.querySelector('#main')
const flags = {
  seed: Math.floor(Math.random() * 0x0fffffff),
  currency: localStorage.currency ? localStorage.currency : null,
  expenses: localStorage.expenses ? localStorage.expenses : null,
  exchange: localStorage.exchange ? localStorage.exchange : null
}
const app = Elm.Main.embed(container, flags)

app.ports.storeCurrency.subscribe(currency => {
  localStorage.currency = currency
})

app.ports.storeExpenses.subscribe(expenses => {
  localStorage.expenses = expenses
})

app.ports.storeExchange.subscribe(exchange => {
  localStorage.exchange = exchange
})
