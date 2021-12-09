$ -> new Acta() if $('[data-action=actas]').length > 0

class Acta

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @editarActa = '.editar-acta'

    # Contenedores
    @$confirmModal = $('#confirm-modal')

    # Plantillas
    @$editarActaTpl = Hogan.compile $('#editar-acta-tpl').html() || ''
    @$editarActaModal = $('#modal-editar-acta')

  bindEvents: ->
    $(document).on 'click', @editarActa, (e) => @mostrarEditarActa(e)
    $(document).on 'shown.bs.modal', (e) => @seleccionarFecha(e)
    $(document).on 'click', @$editarActaModal.find('button[type=submit]').selector, (e) => @enviarFormulario(e)

  enviarFormulario: (e) ->
    e.preventDefault()
    @$confirmModal.find(@$editarActaModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    $.ajax
      url: $form.prop('action')
      data: $form.serialize()
      dataType: 'script'
      type: 'POST'

  mostrarEditarActa: (e) ->
    e.preventDefault()
    data = $(e.target).data('acta')
    unless data
      data = $(e.target).closest('a').data('acta')
    @$confirmModal.html @$editarActaTpl.render(data)
    modal = @$confirmModal.find(@$editarActaModal.selector)
    modal.modal('show')

  seleccionarFecha: (e) ->
    modal = @$confirmModal.find(@$editarActaModal.selector)
    $('#proceeding_fecha').select()
