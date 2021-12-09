$ -> new Materials() if $('[data-action=materiales]').length > 0

class Materials
  _spinner_contador = 0

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @$generarReporteBtn = $('#generar-fisico-valorado')
    @$containerTplReporte = $('#proceeding-delivery')

    @urlMateriales = $('#materiales-data').data('urlMateriales')
    @urlSubarticulos = $('#materiales-data').data('urlSubarticulos')
    @urlReportePdf = $('#materiales-data').data('urlReportePdf')

    @$reporteFisicoValorado = $('#reporte-fisico-valorado')
    @$cabeceraReporte = $('#cabecera-reporte')
    @$botonReporteAbajo = $('#boton-reporte-abajo')
    @$inputCheckboxCeroExistencias = $('#input-cero-existencias')
    @$templateReporteFisicoValorado = Hogan.compile $('#tpl-reporte-fisico-valorado').html() || ''
    @$templateRegistrosSubarticulos = Hogan.compile $('#tpl-td-reporte-fisico-valorado').html() || ''
    @$templateCabeceraReporte = Hogan.compile $('#tpl-cabecera-reporte').html() || ''
    @$templateBotonReporteAbajo = Hogan.compile $('#tpl-boton-reporte-abajo').html() || ''
    @$templateInputCheckboxCeroExistencias = Hogan.compile $('#tpl-input-cero-existencias').html() || ''

  bindEvents: ->
    $(document).on 'click', @$generarReporteBtn.selector, @generarReporte
    $(document).on 'click', $("#generar-reporte-pdf-1").selector, @generarReportePDF
    $(document).on 'click', $("#checkbox-cero-existencias").selector, @mostrarOcultarRegistros

  bloquearGeneracionReporte: () =>
    @$generarReporteBtn.attr("disabled", true)
    @$reporteFisicoValorado.html ''
    @incrementarSpinnerContador()

  desbloquearGeneracionReporte: () =>
    @$generarReporteBtn.removeAttr("disabled")

  obtenerSubarticulos: (codigo, desde, hasta) =>
    @incrementarSpinnerContador()
    $.ajax
      url: @urlSubarticulos.replace('codigo',codigo) + '?desde=' + desde + '&hasta=' + hasta
      type: 'GET'
      dataType: 'JSON'
    .done (xhr) =>
      data = xhr.subarticulos
      total = xhr.subarticulos.total
      id = 'listaSubarticulos_' + codigo
      $('#th-material-' + codigo).after @$templateRegistrosSubarticulos.render(data)
      @actualizarSubTotalMaterial(codigo, total)
      @adicionarNuevoInput(id, 'listaSubarticulos[]', JSON.stringify(data))
      @decrementarSpinnerContador()

  actualizarSubTotalMaterial: (codigo, total) =>
    subtotal = document.createTextNode(total);
    elemento = document.getElementById('subtotal-' + codigo)
    elemento.appendChild(subtotal)

  obtenerTotal: () =>
    arraysubtotales = $('.subtotal-materiales')
    subtotalesFormato = []
    subtotales = []
    i = 0
    while i < arraysubtotales.length
      subtotalesFormato.push { codigo: arraysubtotales[i].getAttribute('id').replace('subtotal-',''), subtotal: arraysubtotales[i].innerText }
      subtotales.push parseFloat(arraysubtotales[i].innerText.replace(/\,/g, ''))
      i++
    total = subtotales.reduce(((a, b) ->
      a + b
    ), 0)
    @adicionarNuevoInput('total', 'total', currencyFormat(total))
    @adicionarNuevoInput('subtotales', 'subtotales', JSON.stringify(subtotalesFormato))
    total = document.createTextNode(currencyFormat(total));
    elemento = document.getElementById('total-materiales')
    elemento.appendChild(total)

  currencyFormat = (num) ->
    num.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')

  generarReporte: (event) =>
    @bloquearGeneracionReporte()
    _ = @
    desde = $('#fecha-desde').val()
    hasta = $('#fecha-hasta').val()
    $.ajax
      url: @urlMateriales + '?' + 'desde=' + desde + '&hasta=' + hasta
      type: 'GET'
      dataType: 'JSON'
    .done (xhr) =>
      data = xhr
      @$reporteFisicoValorado.html @$templateReporteFisicoValorado.render(data)
      @$cabeceraReporte.html @$templateCabeceraReporte.render({desde: desde, hasta: hasta})
      @$botonReporteAbajo.html @$templateBotonReporteAbajo.render({urlReportePdf: _.urlReportePdf})
      @$inputCheckboxCeroExistencias.html @$templateInputCheckboxCeroExistencias.render()
      @adicionarNuevoInput('desde', 'desde', desde)
      @adicionarNuevoInput('hasta', 'hasta', hasta)
      @adicionarNuevoInput('listaMateriales', 'listaMateriales', JSON.stringify(data))
      data.materiales.map (material) ->
        _.obtenerSubarticulos(material.codigo, desde, hasta)
      @desbloquearGeneracionReporte()
      @decrementarSpinnerContador()

  adicionarNuevoInput: (id, name, data) =>
    input = document.createElement("input");
    input.type = "hidden"
    input.name = name
    input.value = data
    $('#inputs-report').append(input)

  incrementarSpinnerContador: () =>
    _spinner_contador +=1
    unless Spinner.activo
      Spinner.show()

  decrementarSpinnerContador: () =>
    _spinner_contador -= 1
    if Spinner.activo && _spinner_contador == 0
      @obtenerTotal()
      Spinner.hide()

  generarReportePDF: (e) =>
    $("#generar-reporte-pdf-2").click()

  mostrarOcultarRegistros: (e) =>
    elemento = document.getElementById('checkbox-cero-existencias')
    if elemento.checked
      $('.registro-cero').addClass('hidden')
      url = document.getElementById('formReportePDF').action
      document.getElementById('formReportePDF').action = @urlReportePdf + '?cero=true'
    else
      $('.registro-cero').removeClass('hidden')
      document.getElementById('formReportePDF').action = @urlReportePdf
