import { Elm } from './Main.elm'

const app = Elm.Main.init({
  node: document.getElementById('app'),
  flags: {
    apiBaseUrl: '/api',
    windowWidth: window.innerWidth,
    windowHeight: window.innerHeight
  }
})

// Handle copy to clipboard from Elm ports
app.ports.copyToClipboard.subscribe(function(text) {
  navigator.clipboard.writeText(text).then(
    () => app.ports.copyResult.send(true),
    () => app.ports.copyResult.send(false)
  )
})