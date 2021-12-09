root = exports ? this

class Spinner
  @activo = false

  @show: () ->
    document.getElementById('spinner-front').classList.add 'show'
    document.getElementById('spinner-back').classList.add 'show'
    @activo = true

  @hide: () ->
    document.getElementById('spinner-front').classList.remove 'show'
    document.getElementById('spinner-back').classList.remove 'show'
    @activo = false

root.Spinner = Spinner
