{log} = console

fs = require 'fs'

module.exports =
  env: (key) ->
    process.env[key]

  ls: (path) ->
    files = []
    for basename in fs.readdirSync path
      files.push { basename }
    files
