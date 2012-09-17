$.ajax
  type: 'POST'
  url: '/rpc'
  data:
    method: 'ls'
    args: ['pdfjs/pdfs']
  dataType: 'json'
  success: (pdfs) ->
    list = $('#list')
    for pdf in pdfs
      {basename} = pdf
      html = "<li><a href=\"reader.html##{basename}\">#{basename}</a></li>"
      list.append html
