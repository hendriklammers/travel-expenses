import './scss/main.scss'
import Elm from './elm/Main'

// Used to generate uuid's inside the Elm program
const seed = Math.floor(Math.random() * 0x0fffffff)
const container = document.querySelector('#main')
const currency = localStorage.currency
  ? JSON.parse(localStorage.currency)
  : null
const app = Elm.Main.embed(container, { seed, currency })

app.ports.storeCurrency.subscribe(currency => {
  localStorage.currency = JSON.stringify(currency)
})

// (function() {
//   'use strict'
//
//   const container = document.querySelector("#container")
//   const app = window.Elm.Main.embed(container)
//   const storage = window.localStorage
//
//   app.ports.sendScore.subscribe( score => {
//     let highscore = storage.getItem('highscore')
//     if (!highscore || highscore < score) {
//       highscore = score
//       storage.setItem('highscore', score)
//     }
//     app.ports.getScore.send(parseInt(highscore))
//   })
//
// }())
