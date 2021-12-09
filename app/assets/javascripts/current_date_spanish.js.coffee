root = exports ? this

# Display growl notices with bootstrap-growl.js (http://bootstrap-growl.remabledesigns.com/)
class CurrentDateSpanish
  MONTHS = new Array("enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre")

  @inWords: ->
    d = new Date()
    day = d.getDate()
    month = MONTHS[d.getMonth()]
    year = d.getFullYear()
    "#{day} de #{month} de #{year}"

root.CurrentDateSpanish = CurrentDateSpanish
