{log} = console

fs   = require 'fs'
os   = require 'os'
path = require 'path'

process.env['HOSTNAME'] = os.hostname()

getType = (stat) ->
  if stat.isFile()
    return 'file'
  if stat.isDirectory()
    return 'directory'
  if stat.isBlockDevice()
    return 'block'
  if stat.isCharacterDevice()
    return 'character'
  if stat.isSymbolicLink()
    return 'symlink'
  if stat.isFIFO()
    return 'fifo'
  if stat.isSocket()
    return 'socket'

module.exports =
  env: (keys...) ->
    values = []
    for key in keys
      values.push process.env[key]
    values

  ls: (_path) ->
    if _path[0] isnt '/'
      _path = path.resolve 'apps', _path
    stats = []
    for basename in fs.readdirSync _path
      abs = path.join _path, basename
      stat = fs.lstatSync abs
      stat.basename = basename
      stat.type = getType stat
      stats.push stat
    stats
