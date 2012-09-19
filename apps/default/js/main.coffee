log = console.log.bind console

rpc = (method, args, success) ->
  $.ajax
    type: 'POST'
    url: '/rpc'
    data: { method, args }
    dataType: 'json'
    success: success

rpc 'ls', ['.'], (files) ->
  list = $ '#list'
  for file in files
    {basename} = file
    list.append "<li><a href=\"/#{basename}\">#{basename}</a></li>"
