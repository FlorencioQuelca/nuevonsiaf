$ -> new AssetsHistorical() if $('[data-action=historical-reviews]').length > 0

class AssetsHistorical
  constructor: ->
    @cacheElements()
    @bindEvents()

  cacheElements: ->
    # containers
    @$containerHistoricalReviews = $('.historical-reviews')
    @$containerLoader = $('.loading')
    # buttons
    @$buttonHistorical = $('.historical')
    # templates
    @$templateAssetsHistorical = Hogan.compile $('#tpl-assets-historical').html() || ''

  bindEvents: ->
    $(document).on 'click', @$buttonHistorical.selector, (e) => @displayHistorical(e)

  displayHistorical: (e) ->
    e.preventDefault()
    @$containerHistoricalReviews.hide()
    @$containerLoader.show()
    $.getJSON e.target.href, (data) =>
      @$containerHistoricalReviews.html @$templateAssetsHistorical.render({proceedings: data})
      @$containerHistoricalReviews.show()
      @$containerLoader.hide()
    .fail (e) =>
      @$containerHistoricalReviews.html @$templateAssetsHistorical.render({error: true})
      @$containerHistoricalReviews.show()
      @$containerLoader.hide()
