root = exports ? this

class BarcodeReader
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # buttons
    @$btnSend = $('#btn-send')
    # textfields
    @$code = $('#code')

  bindEvents: ->
    @setFocusToCode()

  changeToHyphens: ->
    if @checkCodeExists()
      @$code.val Utils.singleQuotesToHyphen(@$code.val())

  checkCodeExists: ->
    @$code && @$code.length > 0

  # Set focus to code textfield every 5 seconds
  setFocusToCode: ->
    setFocus = =>
      @$code.focus() if @checkCodeExists()
    setInterval(setFocus, 5000)

  typeaheadTemplates: ->
    empty: [
      '<p class="empty-message">',
      'No se encontró ningún elemento',
      '</p>'
    ].join('\n')
    suggestion: (data) ->
      Hogan.compile('<p><strong>{{code}}</strong> - <em>{{description}}</em></p>').render(data)

  changeBarcode: (input) ->
    if input.val().indexOf("'") > -1
      value = input.val().replace("'", '-')
      input.val(value)

root.BarcodeReader = BarcodeReader
