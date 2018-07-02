import './scss/main.scss'
import Elm from './elm/Main'

const flag = val => val || null

// Used to generate uuid's inside the Elm program
const container = document.querySelector('#main')
const flags = {
  seed: Math.floor(Math.random() * 0x0fffffff),
  currency: flag(localStorage.currency),
  expenses: flag(localStorage.expenses),
  exchange: flag(localStorage.exchange),
  fixer_api_key: flag(process.env.FIXER_API_KEY)
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
