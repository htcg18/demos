{log} = console

fs   = require 'fs'
os   = require 'os'
path = require 'path'

_   = require 'underscore'
mmm = require 'mmmagic'

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
      stats = []
      after = _.after basenames.length, ->
        cb stats
      for basename in basenames
        do (basename) ->
          absolute = path.join dirname, basename
          fs.stat absolute, (err, stat) ->
            throw err if err
            stat.basename = basename
            stat.type = getType stat
            stats.push stat
            after()
