// Generated by CoffeeScript 1.3.3
(function() {
  var PDF_URL, canvas, canvasContext, goEnd, goNext, goPrev, goStart, log, pageNum, pdf, renderPage;

  log = console.log.bind(console);

  PDF_URL = 'assets/doctorow_down_and_out.pdf';

  PDFJS.disableWorker = true;

  pdf = null;

  pageNum = 1;

  canvas = $('canvas')[0];

  canvasContext = canvas.getContext('2d');

  renderPage = function(num) {
    return pdf.getPage(num).then(function(page) {
      var clientHeight, clientWidth, pageHeight, pageWidth, scale, viewport, _, _ref, _ref1;
      _ref = page.pageInfo.view, _ = _ref[0], _ = _ref[1], pageWidth = _ref[2], pageHeight = _ref[3];
      _ref1 = document.documentElement, clientWidth = _ref1.clientWidth, clientHeight = _ref1.clientHeight;
      scale = Math.min(clientWidth / pageWidth, clientHeight / pageHeight);
      viewport = page.getViewport(scale);
      canvas.height = viewport.height;
      canvas.width = viewport.width;
      return page.render({
        canvasContext: canvasContext,
        viewport: viewport
      });
    });
  };

  goPrev = function() {
    if (!(pageNum > 1)) {
      return;
    }
    return renderPage(--pageNum);
  };

  goNext = function() {
    if (!(pageNum < pdf.numPages)) {
      return;
    }
    return renderPage(++pageNum);
  };

  goStart = function() {
    pageNum = 1;
    return renderPage(pageNum);
  };

  goEnd = function() {
    pageNum = pdf.numPages;
    return renderPage(pageNum);
  };

  key('g', goStart);

  key('shift+g', goEnd);

  key('space, j', goNext);

  key('shift+space, k', goPrev);

  PDFJS.getDocument(PDF_URL).then(function(_pdf) {
    pdf = _pdf;
    return renderPage(pageNum);
  });

}).call(this);
