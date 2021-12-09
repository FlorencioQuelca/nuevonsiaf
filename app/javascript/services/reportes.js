import Api from './api'

class Reporte extends Api {
  constructor () {
    super()
  }

  obtiene_fisico_valorado (reporte = {}) {
    return this.api.post(reporte.url, reporte.datos)
  }

  obtiene_fisico_valorado_descargable (reporte = {}) {
    return this.api.post(reporte.url, reporte.datos, {responseType: 'blob'})
  }

}

export { Reporte as default }
