PORT = process.env.PORT or 5000

{log} = console

express = require 'express'

app = express()
  .use(express.directory __dirname + '/apps')
  .use(express.static __dirname + '/apps')

app.listen PORT, ->
  log "listening on port #{PORT}"
