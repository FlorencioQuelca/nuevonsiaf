$ -> new Bajas() if $('[data-action=bajas]').length > 0

class Bajas
  # lista de activos seleccionados
  _activos = []
  _baja = {}

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # Contenedor de URLs
    @$bajasUrls = $('#bajas-urls')
    # Variables
    @bajasPath = @$bajasUrls.data('bajas')
    # Elementos
    @$barcode = $('#code')
    @$motivo = $('#motivo')
    @$documento = $('#documento')
    @$fecha = $('#fecha')
    @$observacion = $('#observacion_')

    @$activosForm = $('#activos-form')
    @$bajasTbl = $('#bajas-tbl')
    @$buscarBtn = @$activosForm.find('button[type=submit]')
    @$guardarBtn = $('.guardar-btn')
    # Plantillas
    @$activosTpl = Hogan.compile $('#tpl-activo-seleccionado').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

    @$confirmModal = $('#confirm-modal')
    @$confirmarBajaModal = $('#modal-confirmar-baja')

    # Plantillas
    @$confirmarBajaTpl = Hogan.compile $('#confirmar-baja-tpl').html() || ''

  bindEvents: ->
    $(document).on 'click', @$buscarBtn.selector, @buscarActivos
    $(document).on 'change', @$documento.selector, @capturarBaja
    $(document).on 'change', @$fecha.selector, @capturarBaja
    $(document).on 'change', @$observacion.selector, @capturarBaja

    $(document).on 'click', @$guardarBtn.selector, @confirmarBaja
    $(document).on 'click', @$confirmarBajaModal.find('button[type=submit]').selector, (e) => @validarObservacion(e)

  confirmarBaja: (e) =>
    e.preventDefault()
    if @sonValidosDatos()
      @$confirmModal.html @$confirmarBajaTpl.render({})
      modal = @$confirmModal.find(@$confirmarBajaModal.selector)
      modal.modal('show')
    else
      @alert.danger "Complete todos los datos requeridos"

  aceptarConfirmarModal: (e) =>
    e.preventDefault()
    el = @$confirmModal.find('#modal_observacion')
    @$confirmModal.find(@$confirmarBajaModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    @guardarBajaActivosFijos(e)

  validarObservacion: (e) =>
    el = @$confirmModal.find('#modal_observacion')
    if el
      el.parents('.form-group').removeClass('has-error')
      el.next().remove()
      @aceptarConfirmarModal(e)

  adicionarEnLaLista: (data, callback) ->
    _cantidad = 0
    data.forEach (e) =>
      unless @estaEnLaLista(e)
        _cantidad += 1
        _activos.push(e)
    callback(_cantidad > 0)

  buscarActivos: (e) =>
    e.preventDefault()
    _barcode = { barcode: @$barcode.val() }
    $.getJSON @bajasPath, _barcode, @mostrarActivos
    @$barcode.select()

  capturarBaja: =>
    console.log('captando datos')
    _baja.documento = @$documento.val().trim()
    _baja.fecha = @$fecha.val().trim()
    _baja.observacion = @$observacion.val().trim()

  conversionNumeros: ->
    _activos.map (e, i) ->
      e.indice = i + 1
      e.precio_formato = parseFloat(e.precio).formatNumber(2, '.', ',')
      e

  estaEnLaLista: (elemento) ->
    _activos.filter((e) ->
      e.barcode is elemento.barcode
    ).length > 0

  guardarBajaActivosFijos: (e) ->
    if @sonValidosDatos()
      $(e.target).addClass('disabled')
      $.ajax
        url: @bajasPath
        type: 'POST'
        dataType: 'JSON'
        data: { baja: @jsonBaja() }
      .done (baja) =>
        @alert.success "Se guardó correctamente la Baja"
        window.location = "#{@bajasPath}/#{baja.id}"
      .fail (xhr, status) =>
        @alert.danger 'Error al guardar la Baja'
      .always (xhr, status) ->
        $(e.target).removeClass('disabled')
    else
      @alert.danger "Complete todos los datos requeridos"

  jsonBaja: ->
    baja =
      asset_ids: _activos.map((e) -> e.id)
      motivo: @$motivo.val()
      documento: @$documento.val()
      fecha: @$fecha.val()
      observacion: @$observacion.val()
    $.extend({}, baja)

  mostrarActivos: (data) =>
    if data.length > 0
      @adicionarEnLaLista data, (sw) =>
        if sw is true
          @mostrarTabla()
    else
      @alert.danger 'No hay resultado para mostrar'

  mostrarTabla: ->
    json =
      activos: @conversionNumeros(_activos)
      cantidad: _activos.length
      total: @sumaTotal().formatNumber(2, '.', ',')
    @$bajasTbl.html @$activosTpl.render(json)

  sonValidosDatos: ->
    _activos.length > 0 && @$documento.val() && @$fecha.val() && @$motivo.val()

  sumaTotal: ->
    _activos.reduce (total, elemento) ->
      total + parseFloat(elemento.precio)
    , 0
