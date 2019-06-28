import './scss/main.scss'
import { Elm } from './elm/Main'

// Flags should be either a string value or null
const flag = (val: string | undefined) =>
  typeof val === 'undefined' ? null : val

const flags = {
  seed: Math.floor(Math.random() * 0x0fffffff),
  currency: flag(localStorage.currency),
  activeCurrencies: flag(localStorage.activeCurrencies),
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

app.ports.storeActiveCurrencies.subscribe(currencies => {
  localStorage.activeCurrencies = currencies
})

const positionSuccess = ({ coords }: Position) => {
  const { accuracy, latitude, longitude } = coords
  app.ports.updateLocation.send(
    JSON.stringify({
      data: { accuracy, latitude, longitude },
      error: null,
    })
  )
}

const positionError = ({ code }: PositionError) => {
  let error
  switch (code) {
    case 1:
      error = 'PERMISSION_DENIED'
      break
    case 2:
      error = 'PERMISSION_UNAVAILABLE'
      break
    case 3:
      error = 'PERMISSION_TIMEOUT'
      break
  }
  app.ports.updateLocation.send(
    JSON.stringify({
      data: null,
      error,
    })
  )
}

if (navigator.geolocation) {
  navigator.geolocation.watchPosition(positionSuccess, positionError, {
    enableHighAccuracy: false,
    timeout: 5000,
    maximumAge: 0,
  })
}
