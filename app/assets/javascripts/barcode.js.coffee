
$ -> new Barcode() if $('[data-action=barcode]').length > 0

class Barcode
  constructor: ->
    @cacheElements()
    @bindEvents()
    @loadDataAndDisplay()

  cacheElements: ->
    @cacheElementsHogan()
    @$barcodes_urls = $('#barcodes-urls')
    @$containerPreviewBarcodes = $('#preview-barcodes')
    @pdf_barcodes_path = @$barcodes_urls.data('barcodes-pdf')
    @obt_cod_barra_path = @$barcodes_urls.data('barcodes-obt-cod-barra')
    @$btnPrintPdf  = @$containerPreviewBarcodes.find('button.imprimir')
    @$btnBuscar = $('#boton-buscar')
    @$selectType = $('#type')
    @alert = new Notices({ele: 'div.main'})
    @$templatePdfBarcode = Hogan.compile $('#tpl-barcode').html() || ''

  cacheElementsHogan: ->
    @$InputBarCode = $('#code')
    @$InputBarType = $('#type')
    @$InputBarGestion = $('#gestion')

  bindEvents: ->
    $(document).on 'click', @$btnBuscar.selector, (e) => @cargarBarcodes(e)
    $(document).on 'change', @$selectType.selector, (e) => @mostrarGestion(e)
    $(document).on 'click', @$btnPrintPdf.selector,(e) => @printPdf(e)

  mostrarGestion: (e) =>
    if $('#type').val() == 'ACT'
      $('#gestion').addClass 'hide'
      $('#code').attr('placeholder','Código de Barras de Activos Fijos (Ej. 17, 20, 1-10, 3x14, x10)')
    else
      $('#gestion').removeClass 'hide'
      $('#code').attr('placeholder','Número de Ingreso (Ej. 1, 3, 1-2)')

  cargarBarcodes: (e) =>
    document.getElementById('boton-buscar').setAttribute('disabled',true)
    e.preventDefault()
    @loadDataAndDisplay @cargarParametros()

  cargarParametros: =>
    searchParam: @$InputBarCode.val() || 0
    searchType: @$InputBarType.val() || 'ACT'
    searchGestion: @$InputBarGestion.val() || new Date().getFullYear()

  displayBarcodes: =>
    @$containerPreviewBarcodes.find('.row .thumbnail .barcode').each (i, e) ->
      $(e).barcode $(e).data('barcode').toString(), 'code128', { barWidth: 1, barHeight: 50 }

  loadDataAndDisplay: (parametros = {}) =>
    $.getJSON @obt_cod_barra_path, parametros, (data) =>
      document.getElementById('boton-buscar').removeAttribute('disabled')
      if data.length < 1
        if parametros.searchParam != undefined
          @alert.danger "No se encontraron resultados"
        data = { assets: null }
      else
        @alert.success "Búsqueda exitosa"
        data = { assets: data, mostrarPdfBoton: true}
      @previewBarcodes(data)
    .fail =>
      @alert.danger "Error al conectarse con el servidor, vuelva a intentarlo en unos minutos"

  previewBarcodes: (data) =>
    @$containerPreviewBarcodes.html @$templatePdfBarcode.render(data)
    @cacheElementsHogan()
    @displayBarcodes()

  printPdf: (e) =>
    $('#searchParam').val(@cargarParametros().searchParam)
    $('#searchType').val(@cargarParametros().searchType)
    $('#searchGestion').val(@cargarParametros().searchGestion)
