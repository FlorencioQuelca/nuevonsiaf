$ -> new Request() if $('[data-action=request]').length > 0

class Request extends BarcodeReader
  _nro_solicitud = ''
  _observacion = ''

  cacheElements: ->
    @selected_user = null
    @$tdCantidad = $('.td-cantidad')
    @$request_urls = $('#request-urls')
    @$date = $('input#date_restricted')
    @$user = $('input#people')
    @$observacion = $('textarea#observacion')
    @$request = $('#request')
    @$barcode = $('#barcode')
    @$table_request = $('#table_request')
    @$material = $('#material')
    @$article = $('#article')
    @$subarticle = $('#subarticle')
    @$subarticles = $('#subarticles')
    @$amountInput = $('#amount')
    @$selected_user = $('#selected-user')
    @$subtotal_sum = $('#subarticles .subtotal-sum')
    @$selectionSubarticles = $('#selection_subarticles')
    @$selected_subarticles = $('#selected_subarticles')
    @delivery_date = $(".input-group.note_entry_delivery_note_date")
    @invoice_date = $(".input-group.note_entry_invoice_date")
    @$idRequest = $('#request_id').data('id')
    @$btnEditRequest = $('#btn_edit_request')
    @$btnShowRequest = $('#btn-show-request')
    @$btnSaveRequest = $('#btn_save_request')
    @$btnCancelRequest = $('#btn_cancel_request')
    @$btnDeliverRequest = $('#btn_deliver_request')
    @$btnSendRequest = $('#btn_send_request')
    @btnSubarticleRequestPlus = $('#plus_sr')
    @btnSubarticleRequestMinus = $('#minus_sr')
    @btnSubarticleRequestRemove = $('#remove_sr')
    @btnShowNewRequest = $('#btn-show-new-request')
    @$btnCancelNewRequest = $('#btn_cancel_new_request')
    @$btnSaveNewRequest = $('#btn_save_new_request')
    @$templateRequestButtons = Hogan.compile $('#request_buttons').html() || ''
    @$templateRequestAccept = Hogan.compile $('#request_accept').html() || ''
    @$templateRequestInput = Hogan.compile $('#request_input').html() || ''
    @$templateRequestBarcode = Hogan.compile $('#request_barcode').html() || ''
    @$templateNewRequest = Hogan.compile $('#new_request').html() || ''
    @$templateBtnsNewRequest = Hogan.compile $('#cancel_new_request').html() || ''
    @$templateUserInfo = Hogan.compile $('#show_user_info').html() || ''
    @$templateSelectedUser = Hogan.compile $('#selected-user-tpl').html() || ''
    @$templateBusyIndicator = Hogan.compile $('#busy_indicator').html() || ''

    @request_save_url = decodeURIComponent @$request_urls.data('request-id')
    @subarticles_json_url = decodeURIComponent @$request_urls.data('get-subarticles')
    @user_url = decodeURIComponent(@$request_urls.data('users-id'))
    @users_json_url = decodeURIComponent @$request_urls.data('get-users')
    @obtiene_nro_solicitud_url = decodeURIComponent @$request_urls.data('obtiene-nro-solicitud')
    @obtiene_validar_stock_url = decodeURIComponent @$request_urls.data('validar-stocks')

    @alert = new Notices({ele: 'div.main', delay: 2000})

    @$confirmModal = $('#confirm-modal')
    @$confirmarSolicitudModal = $('#modal-confirmar-solicitud')
    @$alertaSolicitudModal = $('#modal-alerta-solicitud')

    # Plantillas
    @$confirmarSolicitudTpl = Hogan.compile $('#confirmar-solicitud-tpl').html() || ''
    @$alertaSolicitudTpl = Hogan.compile $('#alerta-solicitud-tpl').html() || ''

  bindEvents: ->
    $(document).on 'click', @$btnShowRequest.selector, => @show_request()
    $(document).on 'click', @$btnEditRequest.selector, => @edit_request()
    $(document).on 'click', @$btnSaveRequest.selector, => @update_request()
    $(document).on 'click', @$btnCancelRequest.selector, => @cancel_request()
    $(document).on 'click', @$btnDeliverRequest.selector, => @deliver_request()
    $(document).on 'click', @$btnSendRequest.selector, (e) => @send_request(e)
    $(document).on 'click', @btnSubarticleRequestPlus.selector, (e) => @subarticle_request_plus(e)
    $(document).on 'click', @btnSubarticleRequestMinus.selector, (e) => @subarticle_request_minus(e)
    $(document).on 'click', @btnSubarticleRequestRemove.selector, (e) => @subarticle_request_remove(e)
    $(document).on 'click', @btnShowNewRequest.selector, => @show_new_request()
    $(document).on 'click', @$btnCancelNewRequest.selector, => @cancel_new_request()
    $(document).on 'click', @$btnSaveNewRequest.selector, (e) => @save_new_request(e)
    $(document).on 'keyup', @$subarticle.selector, => @changeBarcode(@$subarticle)
    $(document).on 'focus', @$amountInput.selector, (e) => @get_focused(e)
    $(document).on 'keyup', @$amountInput.selector, (e) => @val_amount(e)
    $(document).on 'click', @$confirmarSolicitudModal.find('button[type=submit]').selector, (e) => @validarObservacion(e)
    $(document).on 'click', @$alertaSolicitudModal.find('button[type=submit]').selector, (e) => @aceptarAlertaSolicitud(e)
    $(document).on 'click', @$tdCantidad.selector, (e) => @update_number_input(e)

    if @$material?
      @$article.remoteChained(@$material.selector, @$request_urls.data('subarticles-articles'))
      @$subarticle.remoteChained(@$article.selector, @$request_urls.data('subarticles-array'))
    if @$subarticle?
      @get_subarticles()
    if @$user?
      @get_users()

  val_amount: (e) =>
    valin = document.activeElement.value
    valamount = document.activeElement.max
    regex = /[0-9]|\./
    if !regex.test(valin)
      valin = ''
    if parseInt(valin) < 0
      valin = ''
      document.activeElement.value = '0'
      @open_modal('la cantidad no puede ser negativa')
    if parseInt(valin) > parseInt(valamount)
      document.activeElement.value = parseInt(valamount)
      @open_modal("Ya no se encuentra la cantidad requerida en el inventario del Artículo")
    if valin == ''
      document.activeElement.value = '0'

  get_focused: (e) =>
    td = e.currentTarget
    @$des = (td.closest('tr')).getElementsByClassName('input-sm')
    @$des.amount.select()

  confirmarSolicitud: (e) =>
    e.preventDefault()
    url = @obtiene_nro_solicitud_url + "?d=" + $("#date_restricted").val()
    $.ajax
      url: url
      type: 'GET'
      dataType: 'JSON'
    .done (xhr) =>
      data = xhr
      if data["tipo_respuesta"]
        if data["tipo_respuesta"] == "confirmacion"
          @$confirmModal.html @$confirmarSolicitudTpl.render(data)
          modal = @$confirmModal.find(@$confirmarSolicitudModal.selector)
          modal.modal('show')
        else if data["tipo_respuesta"] == "alerta"
          @$confirmModal.html @$alertaSolicitudTpl.render(data)
          modal = @$confirmModal.find(@$alertaSolicitudModal.selector)
          modal.modal('show')
      else
        @save_new_request()

  aceptarConfirmarSolicitud: (e) =>
    e.preventDefault()
    el = @$confirmModal.find('#modal_observacion')
    if el
      _observacion = el.val()
    @$confirmModal.find(@$confirmarSolicitudModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    @save_new_request()

  validarObservacion: (e) =>
    el = @$confirmModal.find('#modal_observacion')
    if el
      valor = $.trim(el.val())
      if valor
        el.parents('.form-group').removeClass('has-error')
        el.next().remove()
        @aceptarConfirmarSolicitud(e)
      else
        el.parents('.form-group').addClass('has-error')
        el.after('<span class="help-block">no puede estar en blanco</span>') unless $('span.help-block').length
        false

  aceptarAlertaSolicitud: (e) ->
    e.preventDefault()
    @$confirmModal.find(@$alertaSolicitudModal.selector).modal('hide')
    $form = $(e.target).closest('form')
    false

  show_request: ->
    @validar_cantidades(@$idRequest, @generar_datos())

  generar_datos: ->
    data = []
    @$table_request.find('tbody > tr').each (i) ->
      data.push { id: this.getAttribute("id"), cantidad: $(this).find("input").val() }
    data

  validar_cantidades: (id, data) ->
    url = @obtiene_validar_stock_url.replace(/{id}/, id)
    sw = 0
    _ = @
    $.ajax
      url: url
      type: 'POST'
      dataType: 'JSON'
      data: { cantidades: data }
    .done (respuesta) =>
      $.map(respuesta.data, (val, i) ->
        elemento = $('#' + val.id)
        cantidad_solicitada = parseInt(elemento.find('td')[5].innerText)
        if elemento.find('input').val() > cantidad_solicitada
          if val.verificacion
            _.open_modal('La cantidad a entregar es mayor a la cantidad solicitada.')
          else
            _.open_modal(val.mensaje)
          sw = 1
          elemento.find('input').addClass('error-input')
        else
          if val.verificacion
            if elemento.find('input').val() < 0
              _.open_modal('La cantidad a entregar es menor a 0.')
              sw = 1
              elemento.find('input').addClass('error-input')
            else
              elemento.find('input').removeClass('error-input')
          else
            _.open_modal(val.mensaje)
            sw = 1
            elemento.find('input').addClass('error-input')
      )
      if sw == 0
        @$table_request.find('input').each ->
          val = parseInt($(this).val())
          val = if val then val else 0
          $(this).parent().html val
        @$table_request.find('.text-center').hide()
        @$table_request.append @$templateRequestButtons.render()
    .fail (xhr, status) =>
      @alert.danger 'Se ha producido un error vuelva intentarlo.'

  edit_request: ->
    @show_buttons()
    @$request.find('table thead tr').append '<th>Cantidad a entregar</th>'
    @$request.find('table tbody tr').append @$templateRequestInput.render()
    @$request.find('.td-cantidad' ).css 'cursor', 'pointer'
    @$request.find('#td-cantidad-header' ).css 'cursor', 'pointer'
    @bloquearInexistencias()
    $('#td-cantidad-header').click =>
      @update_all_columns()

  bloquearInexistencias: =>
    @$request.find('table tbody tr').each (i, fila) ->
      if isNaN($(fila).find('.td-cantidad').text().trim())
        $(fila).find('.td-cantidad')
          .removeClass('td-cantidad')
          .css('cursor', 'auto')
        $(fila).find('.note')
          .text(0)

  update_all_columns: =>
    $('#table_request table tbody tr').each (i, el)->
      valor = $(el).find('.td-cantidad').text()
      unless isNaN(valor)
        $(el).find('.note input.input-sm').val(valor)

  update_number_input: (e) ->
    td = e.currentTarget
    @$des = (td.closest('tr')).getElementsByClassName('input-sm')
    @$des.amount.value = (parseInt(td.textContent))
    @$des.amount.select()

  update_request: ->
    @$table_request.find('.text-center').hide()
    @$table_request.append @$templateBusyIndicator.render()
    materials = $.map(@$request.find('tbody tr'), (val, i) ->
      id: val.id
      amount_delivered: $(val).find('td.col-md-1').text()
    )
    data = { status: 'pending', subarticle_requests_attributes: materials }
    $.ajax
      type: "PUT"
      url: @request_save_url.replace(/{id}/, @$idRequest)
      data: { request: data }
      dataType: 'json'
      complete: (data, xhr) ->
        window.location = window.location

  cancel_request: ->
    @$table_request.find('.text-center').show()
    @$table_request.find('.text-center').next().remove()
    @edit_request()

  deliver_request: ->
    @show_buttons()
    $('#btn-show-request').remove()
    @$barcode.html @$templateRequestBarcode.render()
    $('#code').focus()

  send_request: (e) ->
    e.preventDefault()
    @$code = $('#code')
    if @$code.val()
      @changeToHyphens()
      url = @request_save_url.replace(/{id}/, @$idRequest)
      $.getJSON url, { barcode: @$code.val().trim(), user_id: @$functionary }, (data) => @request_delivered(data)
    else
      @open_modal('Debe ingresar un Código de Barras')

  show_buttons: ->
    @$request.prev().find(".buttonRequest").remove()
    @$table_request.find('.buttons-actions.text-center').html @$templateRequestAccept.render()

  request_delivered: (data) ->
    if data
      if data.amount
        if @$table_request.find("tr##{data.id} td.delivered span.glyphicon-ok").length
          @open_modal("#{data.amount_delivered} es límite de entrega del Artículo con código de barra '#{@$code.val()}'")
        else
          @$table_request.find("tr##{data.id} td.amount_delivered").html data.total_delivered
          if data.total_delivered == data.amount_delivered
            @$table_request.find("tr##{data.id} td.delivered span").addClass 'glyphicon-ok'
            window.location = window.location unless @$table_request.find('.delivered span:hidden').length
      else
        @open_modal("El inventario del Artículo con código de barra '#{@$code.val()}' es 0")
    else
      @open_modal('No se encuentra el Artículo en la lista')
    @$code.select()

  input_to_text: ->
    @$table_request.find('td.col-md-2').each ->
      $(this).html "<input class='form-control input-sm' type='text' value=#{$(this).text()}>" if $(this).next().text() < $(this).text()

  open_modal: (content) ->
    @alert.danger content

  get_subarticles: ->
    bestPictures = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("description")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 100
      remote:
        url: @subarticles_json_url,
        ajax:
          beforeSend: (xhr, settings) ->
            if  $(document.activeElement).typeahead != null
              $(document.activeElement).addClass('loadinggif')
          complete: ->
            $(document.activeElement).removeClass('loadinggif')
    )
    bestPictures.initialize()
    @$subarticle.typeahead null,
      source: bestPictures.ttAdapter()
      templates: @typeaheadTemplates()
    .on 'typeahead:selected', (evt, data) => @add_subarticle(evt, data)

  add_subarticle: (evt, data) ->
    if @$subarticles.find("tr##{data.id}").length
      @open_modal("El Artículo '#{data.description}' ya se encuentra en lista")
    else
      if @$selectionSubarticles.find('#people').length > 0
        if data.stock == 0
          @open_modal("El stock del producto #{data.description} es 0")
        else
          @$subarticles.append @$templateNewRequest.render(data)
      else
        $(@$templateNewRequest.render(data)).insertBefore(@$subtotal_sum)

  subarticle_request_remove: ($this) ->
    @get_amount($this).remove()

  get_amount: ($this) ->
    $($this.currentTarget).parent().parent().parent()

  show_new_request: ->
    if @$subarticles.find('tr').length
      if @selected_user
        if @$date.val().trim()
          @btnShowNewRequest.hide()
          @$selectionSubarticles.hide()
          table = @$subarticles.parent().clone()
          table.find('.actions-request').remove()
          table.find('.amount').each (l) ->
            $(this).text($(this).find('#amount').val() || $(this).text().trim())
          table.find('thead tr').prepend '<th>#</th>'
          table.find('#subarticles tr').each (i) ->
            $(this).prepend "<td>#{ i+1 }</td>"
          @$selected_subarticles.append table
          @$selected_subarticles.append @$templateBtnsNewRequest.render()
          @showUserInfo()
        else
          @open_modal("Se debe especificar una fecha")
      else
        @open_modal("Falta seleccionar funcionario")
    else
      @open_modal("Debe seleccionar al menos un subartículo")

  cancel_new_request: ->
    @btnShowNewRequest.show()
    @$selectionSubarticles.show()
    @$selected_subarticles.empty()

  parse_date_time: (str_date)->
    dateParts = str_date.split("/");
    now = new Date()
    date = [dateParts[2], dateParts[1], dateParts[0]]
    time = [now.getHours(), now.getMinutes(), now.getSeconds()]
    "#{date.join('/')} #{time.join(':')}"

  save_new_request: ->
    @$selected_subarticles.find('.text-center').hide()
    @$selected_subarticles.append @$templateBusyIndicator.render()
    subarticles = $.map(@$subarticles.find('tr'), (val, i) ->
      subarticle_id: val.id
      amount: $(val).find('input').val()
    )
    json_data =
      status: 'initiation'
      user_id: @selected_user.id
      observacion: @$observacion.val()
      subarticle_requests_attributes: subarticles
      created_at: @parse_date_time(@$date.val()) # yyyy/mm/dd HH:MM:SS
    $.post @request_save_url.replace(/{id}/, ''), { request: json_data }, null, 'script'

  showUserInfo: ->
    result = $.extend(@selected_user, {
      date: @$date.val(),
    })
    $user = @$templateUserInfo.render(result)
    $table = @$selected_subarticles.find("table")
    $($user).insertBefore($table)

  get_users: ->
    bestPictures = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("name")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 100
      remote:
        url: @users_json_url,
        ajax:
          beforeSend: (xhr, settings) ->
            if ($(document.activeElement).typeahead != null)
              $(document.activeElement).addClass('loadinggif')
          complete: ->
            $(document.activeElement).removeClass('loadinggif')

    )
    bestPictures.initialize()
    @$user.typeahead null,
      displayKey: 'name'
      source: bestPictures.ttAdapter(),

      templates:
        empty: [
          '<p class="empty-message">',
          'No se encontró ningún elemento',
          '</p>'
        ].join('\n')
        suggestion: (data) ->
          Hogan.compile('<p><b>{{name}}</b><p class="text-muted">{{title}}</p></p>').render(data)
    .on 'typeahead:selected', (evt, data) => @add_user_id(evt, data)

  add_user_id: (evt, data) ->
    @selected_user = data
    @display_selected_user()

  display_selected_user: ->
    selected_user = @$templateSelectedUser.render(@selected_user)
    @$selected_user.html(selected_user)
