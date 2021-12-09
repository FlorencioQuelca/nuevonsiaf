$ -> new Reportes() if $('[data-action=reportes]').length > 0

if $('[data-action=reportes-activos]').length > 0
  $(window).load ->
    csv = ''
    $('table > thead').find('tr').each ->
      sep = ''
      $(this).find('th').each ->
        csv += sep + $(this)[0].innerHTML
        sep = ';'
      csv += '\n'
    $('table > tbody').find('tr').each ->
      sep = ''
      $(this).find('td').each ->
        csv += sep + $(this)[0].innerHTML
        sep = ';'
      csv += '\n'
    $('table > tbody').find('tr:last').each ->
      sep = ';;;;'
      $(this).find('th').each ->
        csv += sep + $(this)[0].innerHTML
        sep = ';'
      csv += '\n'
      return
    window.URL = window.URL or window.webkiURL
    blob = new Blob([ csv ])
    blobURL = window.URL.createObjectURL(blob)
    $('#download_csv').attr('href', blobURL).attr('download', 'data.csv')

class Reportes

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @$descargarKardexBtn = $('.descargar-kardex')

  bindEvents: ->
    $(document).on 'click', @$descargarKardexBtn.selector, @deshabilitarBoton

  deshabilitarBoton: (event) ->
    $(event.target).addClass('disabled')
