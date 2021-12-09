$ -> new Gestiones() if $('[data-action=gestiones]').length > 0

class Gestiones

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # elemento
    @$cerrarEnlace = $('#cerrar-gestion-link')
    @$modalId = '#modal-cerrar-gestion'
    @$urlCierreGestion = @$cerrarEnlace.data('url')
    # Contenedor
    @$confirmModal = $('#confirm-modal')
    # Plantillas
    @$activosTpl = Hogan.compile $('#cerrar-gestion-tpl').html() || ''
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})

  bindEvents: ->
    $(document).on 'click', @$cerrarEnlace.selector, @modalCerrarGestion
    $(document).on 'click', $(@$modalId).find('.aceptar').selector, @cerrarGestion

  cerrarGestion: (e) =>
    e.preventDefault()
    $(e.target).prop('disabled', true)
    $.ajax
      url: @$urlCierreGestion
      type: 'POST'
      dataType: 'JSON'
      data: { _method: 'PUT' }
    .done (gestion) =>
      @$confirmModal.find(@$modalId).modal('hide')
      @alert.success "Se cerró la gestión correctamente"
      window.location = window.location.pathname
    .fail (xhr, status) =>
      @$confirmModal.find(@$modalId).modal('hide')
      @alert.danger 'Error al cerrar la gestión, vuelva a intentarlo más tarde'

  modalCerrarGestion: (e) =>
    e.preventDefault()
    @$confirmModal.html @$activosTpl.render()
    @$confirmModal.find(@$modalId).modal('show')
