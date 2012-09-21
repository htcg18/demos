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

asyncMap = (list, iterator, cb) ->
  {length} = list
  results = new Array length
  after = _.after length, -> cb results
  for item, i in list
    do (i) ->
      iterator item, (err, result) ->
        throw err if err
        results[i] = result
        after()

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
      absolutes = (path.join dirname, basename for basename in basenames)
      asyncMap absolutes, fs.stat, (stats) ->
        for stat, i in stats
          stat.basename = basenames[i]
          stat.type = getType stat
        cb stats
