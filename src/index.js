import './scss/main.scss'
import Elm from './elm/Main'

// Used to generate uuid's inside the Elm program
const seed = Math.floor(Math.random() * 0x0fffffff)
const container = document.querySelector('#main')
Elm.Main.embed(container, seed)
