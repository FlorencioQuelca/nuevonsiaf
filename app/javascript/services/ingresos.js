import Api from './api'

class Ingreso extends Api {
  constructor () {
    super()
  }

  actualiza (ingreso = {}) {
    return this.api.put(ingreso.url, ingreso.datos)
  }

}

export { Ingreso as default }
