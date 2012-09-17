log = console.log.bind console

PDF_URL = 'assets/doctorow_down_and_out.pdf'
NAMESPACE = 'pdfjs'

PDFJS.disableWorker = true # docs where

pdf = null
pageNum = localStorage["#{NAMESPACE}.pageNum"] or 1
canvas = $('canvas')[0]
canvasContext = canvas.getContext '2d'

renderPage = (num) ->
  localStorage["#{NAMESPACE}.pageNum"] = num
  pdf.getPage(num).then (page) ->
    [_, _, pageWidth, pageHeight] = page.pageInfo.view
    {clientWidth, clientHeight} = document.documentElement

    scale = Math.min (clientWidth / pageWidth), (clientHeight / pageHeight)

    viewport = page.getViewport scale
    canvas.height = viewport.height
    canvas.width  = viewport.width

    page.render { canvasContext, viewport }

goPrev = ->
  return unless pageNum > 1
  renderPage --pageNum

goNext = ->
  return unless pageNum < pdf.numPages
  renderPage ++pageNum

goStart = ->
  pageNum = 1
  renderPage pageNum

goEnd = ->
  pageNum = pdf.numPages
  renderPage pageNum

key 'g', goStart
key 'shift+g', goEnd
key 'space, j', goNext
key 'shift+space, k', goPrev

PDFJS.getDocument(PDF_URL).then (_pdf) ->
  pdf = _pdf
  renderPage pageNum
