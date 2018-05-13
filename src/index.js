import './scss/main.scss'
import Elm from './elm/Main'

// Used to generate uuid's inside the Elm program
const seed = Math.floor(Math.random() * 0x0fffffff)
const container = document.querySelector('#main')
const currency = localStorage.currency
  ? JSON.parse(localStorage.currency)
  : null
const expenses = localStorage.expenses ? localStorage.expenses : null
const app = Elm.Main.embed(container, { seed, currency, expenses })

app.ports.storeCurrency.subscribe(currency => {
  localStorage.currency = JSON.stringify(currency)
})

app.ports.storeExpenses.subscribe(expenses => {
  localStorage.expenses = expenses
})
