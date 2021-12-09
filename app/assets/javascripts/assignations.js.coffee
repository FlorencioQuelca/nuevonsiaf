$ -> new Assignations() if $('[data-action=assignation]').length > 0

class Assignations extends BarcodeReader
  _assets = []
  _proceeding_type = 'E'
  _user = null

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @$assignation_urls = $('#assignation-urls')
    # URLs
    @admin_assets_search_url = @$assignation_urls.data('admin-assets')
    @proceedings_url = @$assignation_urls.data('proceedings')
    @user_url = decodeURIComponent(@$assignation_urls.data('users-id'))
    # Containers
    @$containerTplSelectedAssets = $('#container-tpl-selected-assets')
    @$containerTplSelectedUser = $('#container-tpl-selected-user')
    @$containerSelectUser = $('#container-select-user')
    @$containerTplSuccessMessage = $('#success-message')
    @$containerTplProceedingDelivery = $('#proceeding-delivery')
    # forms & inputs
    @$building = $('#building')
    @$department = $('#department')
    @$user = $('#user')
    # buttons
    @$btnAssignation = $('#btn_assignation')
    @$btnBack = @$containerTplSelectedAssets.find('button[data-type=back]')
    @$btnCancel = @$containerTplProceedingDelivery.find('button[data-type=cancel]')
    @$btnNext = @$containerTplSelectedAssets.find('button[data-type=next]')
    @$btnReturn = $('#btn_cancel')
    @$btnSave = @$containerTplProceedingDelivery.find('button[data-type=save]')
    # Growl Notices
    @alert = new Notices({ele: 'div.main'})
    # Hogan templates
    @$templateProceedingDelivery = Hogan.compile $('#tpl-proceeding-delivery').html() || ''
    @$templateSelectedAssets = Hogan.compile $('#tpl-selected-assets').html() || ''
    @$templateSelectedUser = Hogan.compile $('#tpl-selected-user').html() || ''
    @$templateSuccessMessage = Hogan.compile $('#tpl-success-message').html() || ''
    @cacheTplElements()

  cacheTplElements: ->
    $form = $('form[data-action=assignation]')
    @$code = $form.find('input[type=text]')
    @$btnSend = $form.find('button[type=submit]')

  bindEvents: ->
    @setFocusToCode()
    if @$building?
      @$department.remoteChained(@$building.selector, @$assignation_urls.data('assets-departments'))
      @$user.remoteChained(@$department.selector, @$assignation_urls.data('assets-users'))
    $(document).on 'click', @$btnAssignation.selector, (e) => @displayContainer(e)
    $(document).on 'click', @$btnBack.selector, (e) => @backToSelectUser(e)
    $(document).on 'click', @$btnCancel.selector, (e) => @backToSelectAssets(e)
    $(document).on 'click', @$btnNext.selector, (e) => @previewProceeding(e)
    $(document).on 'click', @$btnReturn.selector, (e) => @redirectToAssets(e, @proceedings_url)
    $(document).on 'click', @$btnSave.selector, (e) => @saveSelectedAssets(e)
    $(document).on 'click', @$btnSend.selector, (e) => @checkAssetIfExists(e)

  displayAssetRows: (asset = null) ->
    @$containerTplSelectedAssets.html @$templateSelectedAssets.render(@assetsJSON())
    @$containerTplSelectedAssets.show()
    if asset
      $("#asset_#{asset.id}").hide().toggle('highlight')

  assetsJSON: ->
    assets: _assets.map (a, i) -> a.index = i + 1; a
    total: _assets.length

  backToSelectUser: (e) ->
    e.preventDefault()
    @$containerSelectUser.show()
    @$containerTplSelectedAssets.hide()
    @$containerTplSelectedUser.hide()

  backToSelectAssets: (e) ->
    e.preventDefault()
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

  checkSelectedUser: ->
    @$building.val() && @$department.val() && @$user.val()

  displayContainer: (e) ->
    e.preventDefault()
    if @checkSelectedUser()
      @$containerSelectUser.hide()
      @showUserInfo @$user.val()
      @displayAssetRows()
    else
      @alert.info 'Seleccione <b>Entidad</b>, <b>Unidad</b>, y <b>Funcionario</b>'

  displaySearchAsset: (code, data) =>
    if data.estado == 1
      @displaySelectedAssets(data.activo)
    else
      @alert.danger data.mensaje || 'No es posible realizar la asignación'

  displaySelectedAssets: (asset) ->
    index = @searchInLocalAssets(asset)
    if index >= 0
      @removeAssetRow(asset)
      _assets.splice(index, 1) # remove asset
    else
      _assets.unshift(asset)
      @displayAssetRows(asset)

  previewProceeding: (e) ->
    e.preventDefault()
    if _assets.length > 0
      assignation =
        entity: _user.entity_name
        assets: _assets
        count: _assets.length
        devolution: false
        proceedingDate: CurrentDateSpanish.inWords()
        userCi: _user.ci
        userName: _user.name
        userTitle: _user.title
        userDepartment: _user.department_name
      @$containerTplProceedingDelivery.html @$templateProceedingDelivery.render(assignation)
      @$containerTplProceedingDelivery.show()
      @$containerTplSelectedAssets.hide()
      @$containerTplSelectedUser.hide()
    else
      @alert.danger 'Debe seleccionar al menos un Activo'

  redirectToAssets: (e, url) ->
    e.preventDefault()
    window.location = url

  removeAssetRow: (asset) ->
    $("#asset_#{asset.id}").hide 'slow', => @displayAssetRows()

  saveSelectedAssets: (e) ->
    e.preventDefault()
    if _assets.length > 0
      @$btnSave.prop('disabled', true)
      @$btnCancel.prop('disabled', true)
      json_data = { user_id: _user.id, asset_ids: (_assets.map (a) -> a.id), proceeding_type: _proceeding_type }
      $.post(@proceedings_url, { proceeding: json_data }, (data) =>
        if window.plantillas == null
          message =
            devolution: false
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
    $.getJSON @admin_assets_search_url, {code: code}, (data) ->
      callback(code, data)

  searchInLocalAssets: (asset) ->
    index = -1
    for obj, i in _assets
      if obj.code is asset.code
        index = i
    return index

  showUserInfo: (user_id) ->
    if _user && _user.id is parseInt(user_id)
      @$containerTplSelectedUser.show()
      @$code.select()
    else
      $.getJSON @user_url.replace(/{id}/g, @$user.val()), (data) =>
        _user = data
        @$containerTplSelectedUser.html @$templateSelectedUser.render(_user)
        @$containerTplSelectedUser.show()
        @cacheTplElements()
        @$code.select()
