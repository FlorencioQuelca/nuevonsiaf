jQuery ->
  proceeding = new DisplayProceeding()

  #Page Numbering
  window.number_pages = ->
    vars = {}
    x = document.location.search.substring(1).split("&")
    for i of x
      z = x[i].split("=", 2)
      vars[z[0]] = unescape(z[1])
    x = [ "frompage", "topage", "page", "webpage", "section", "subsection", "subsubsection" ]
    for i of x
      y = document.getElementsByClassName(x[i])
      j = 0
      while j < y.length
        y[j].textContent = vars[x[i]]
        ++j


class DisplayProceeding
  constructor: ->
    @cacheElements()
    @displayProceeding()

  cacheElements: ->
    @$proceedingDelivery = $('#proceeding-delivery[data-type=proceeding]')
    @tplProceedingDelivery = Hogan.compile $('#tpl-proceeding-delivery').html() || ''

  displayProceeding: ->
    data = @$proceedingDelivery.data()
    @$proceedingDelivery.html @tplProceedingDelivery.render(data)
