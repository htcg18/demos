{log} = console

fs   = require 'fs'
os   = require 'os'
path = require 'path'

mmm  = require 'mmmagic'
step = require 'step'

magic = new mmm.Magic mmm.MAGIC_MIME_TYPE

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
  env: (args, cb) ->
    values = []
    for arg in args
      values.push process.env[arg]
    cb values

  ls: (args, cb) ->
    [dirname] = args
    if dirname[0] isnt '/'
      dirname = path.resolve 'apps', dirname
    fs.readdir dirname, (err, basenames) ->
      throw err if err
      step ->
        group = @group()
        for basename in basenames
          abs = path.join dirname, basename
          fs.stat abs, group()
        return # prevent coffeescript from returning a value and confusing step
      , (err, stats) ->
        throw err if err
        for stat, i in stats
          stat.basename = basenames[i]
          stat.type = getType stat
        cb stats
