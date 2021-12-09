$ -> new Subarticulos() if $('[data-action=subarticulos]').length > 0

class Subarticulos

  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    @$form = $('form.form_entry')
    @$entrySubarticle = @$form.find('.entry_subarticle')
    @$cantidad = @$entrySubarticle.find('.amount')
    @$costoUnitario = @$entrySubarticle.find('.unit_cost')
    @$costoTotal = @$entrySubarticle.find('.total_cost')

  bindEvents: ->
    $(document).on 'keyup', @$cantidad.selector, @calcularCostoTotal
    $(document).on 'keyup', @$costoUnitario.selector, @calcularCostoTotal

  calcularCostoTotal: (e) =>
    $div = $(e.target).closest('.entry_subarticle')
    $cantidad = $div.find('.amount').val() || 0
    $costoUnitario = $div.find('.unit_cost').val() || 0
    $entryCost = $div.find('.entry_cost')
    $costoTotal = $div.find('.total_cost')
    $total = @round($cantidad * $costoUnitario, 2)
    $costoTotal.val($total)
    $entryCost.text($total.formatNumber(2, '.', ','))

  # Extractado de http://www.jacklmoore.com/notes/rounding-in-javascript/
  round: (value, decimals) ->
    Number(Math.round(value+'e'+decimals)+'e-'+decimals)
