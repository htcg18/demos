PORT = process.env.PORT or 5000

{log} = console

express = require 'express'

shell = require './lib/shell'

app = express()
  .use(express.static __dirname + '/apps')
  .use(express.bodyParser())

app.get '/', (req, res) ->
  res.redirect '/default'

app.post '/rpc', (req, res) ->
  {method, args} = req.body
  res.json shell[method].apply shell, args

app.listen PORT, ->
  log "listening on port #{PORT}"
