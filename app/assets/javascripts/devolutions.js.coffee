$ -> new Devolutions() if $('[data-action=devolution]').length > 0

class Devolutions extends BarcodeReader
  _assets = []
  _proceeding_type = 'D'
  _user = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    $form = $('form')
    @$devolution_urls = $('#devolution-urls')
    # URLs
    @assets_search_url = @$devolution_urls.data('assets-search')
    @proceedings_url = @$devolution_urls.data('proceedings')
    # Containers
    @$containerBarcode = $('div[data-action=devolution]')
    @$containerTplProceedingDelivery = $('#proceeding-delivery')
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    @$containerTplSuccessMessage = $('#success-message')
    # textfields
    @$code = $form.find('input[type=text]')
    # buttons
    @$btnBack = @$containerTplProceedingDelivery.find('button[data-type=cancel]')
    @$btnCancel = @$containerTplSelectedAssets.find('button[data-type=reset]')
    @$btnNext = @$containerTplSelectedAssets.find('button[data-type=next]')
    @$btnSave = @$containerTplProceedingDelivery.find('button[data-type=save]')
    @$btnSend = $form.find('button[type=submit]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # Hogan templates
    @$templateProceedingDelivery = Hogan.compile $('#tpl-proceeding-delivery').html() || ''
    @$templateSelectedAssets = Hogan.compile $('#tpl-selected-assets').html() || ''
    @$templateSelectedUser = Hogan.compile $('#tpl-selected-user').html() || ''
    @$templateSuccessMessage = Hogan.compile $('#tpl-success-message').html() || ''

  bindEvents: ->
    # @setFocusToCode()
    if @checkCodeExists()
      $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e)
    $(document).on 'click', @$btnBack.selector, (e) => @backToSelectUser(e)
    $(document).on 'click', @$btnCancel.selector, (e) => @resetDevolutionViews(e)
    $(document).on 'click', @$btnNext.selector, (e) => @previewProceeding(e)
    $(document).on 'click', @$btnSave.selector, (e) => @saveSelectedAssets(e)

  displayAssetRows: (asset = null) ->
    @$containerTplSelectedAssets.html @$templateSelectedAssets.render(@assetsJSON())
    if asset
      $("#asset_#{asset.id}").hide().toggle('highlight')

  assetsJSON: ->
    assets: _assets.map (a, i) -> a.index = i + 1; a
    total: _assets.length

  backToSelectUser: (e) ->
    e.preventDefault()
    @$containerBarcode.show()
    @$containerTplProceedingDelivery.hide()
    @$containerTplSelectedAssets.show()
    @$containerTplSelectedUser.show()
    @$code.focus()

  checkAssetIfExists: (e) ->
    e.preventDefault()
    @changeToHyphens()
    code = @$code.val().trim()
    if code
      @searchInAssets(code, @displaySearchAsset)
    else
      @alert.info "Introduzca un Código de Activo"
    @$code.select()

  displaySearchAsset: (code, data) =>
    if data.estado == 1
      if @displaySelectedUser(data.activo.user)
        @displaySelectedAssets(data.activo)
      else
        @alert.danger "El Activo con código <b>#{code}</b> pertenece a otro funcionario: <br/><b>#{data.activo.user.name}</b> (<em>#{data.user.title}</em>)"
    else
       @alert.danger data.mensaje

  displaySelectedAssets: (asset) ->
    index = @searchInLocalAssets(asset)
    if index >= 0
      @removeAssetRow(asset)
      _assets.splice(index, 1) # remove asset
      if _assets.length is 0 # reset _user var
        _user = null
        @showUserInfo()
    else
      _assets.unshift(asset)
      @displayAssetRows(asset)

  displaySelectedUser: (user) ->
    if @isUserSelected()
      return _user.id is user.id
    else
      _user = user
      @showUserInfo()
      return true

  isUserSelected: ->
    _user?

  previewProceeding: (e) ->
    e.preventDefault()
    if _assets.length > 0
      assignation =
        entity: _user.entity_name
        assets: _assets
        count: _assets.length
        devolution: true
        proceedingDate: CurrentDateSpanish.inWords()
        userName: _user.name
        userTitle: _user.title
        userCi: _user.ci
        obsAsset: $('form#form_obs').find('textarea#ta_obs').val() || 'Ninguno'
        userDepartment: _user.department_name
      @$containerTplProceedingDelivery.html @$templateProceedingDelivery.render(assignation)
      @$containerTplProceedingDelivery.show()
      @$containerTplSelectedAssets.hide()
      @$containerTplSelectedUser.hide()
      @$containerBarcode.hide()
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  removeAssetRow: (asset) ->
    $("#asset_#{asset.id}").hide 'slow', => @displayAssetRows()

  resetDevolutionViews: (e) ->
    _assets = []
    _user = null
    @$containerTplSelectedUser.html('')
    @$containerTplSelectedAssets.html('')
    @$code.val('').select()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    if _assets.length > 0
      @$btnSave.prop('disabled', true)
      @$btnCancel.prop('disabled', true)
      json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: _proceeding_type, observaciones: ($('form#form_obs').find('textarea#ta_obs').val() || 'Ninguno') }
      $.post(@proceedings_url, { proceeding: json_data }, (data) =>
        if window.plantillas == null
          message =
            devolution: true
            proceeding_path: window.proceeding_path
            user_name: _user.name
            user_title: _user.title
            total_assets: _assets.length
          @$containerTplProceedingDelivery.hide()
          @$containerTplSuccessMessage.html @$templateSuccessMessage.render(message)
          @$containerTplSuccessMessage.show()
      , 'script').fail =>
        @alert.danger 'Ocurrió un error al guardar el Acta, vuelva a intentarlo por favor'
        @$containerTplProceedingDelivery.show()
        @$containerTplSuccessMessage.hide()
        @$btnSave.prop('disabled', false)
        @$btnCancel.prop('disabled', false)
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  searchInAssets: (code, callback) ->
    $.ajax
      url: @assets_search_url
      type: 'GET'
      dataType: 'JSON'
      data: { code: code }
    .done (data) -> callback(code, data)

  searchInLocalAssets: (asset) ->
    index = -1
    for obj, i in _assets
      if obj.code is asset.code
        index = i
    return index

  showUserInfo: ->
    @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
