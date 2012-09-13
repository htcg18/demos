PORT = process.env.PORT or 5000

{log} = console

express = require 'express'

app = express()
  .use express.static __dirname + '/app'

app.listen PORT, ->
  log "listening on port #{PORT}"
