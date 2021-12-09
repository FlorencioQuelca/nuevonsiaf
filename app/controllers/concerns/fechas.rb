module Fechas
  extend ActiveSupport::Concern

  def get_fecha(params, nombre = :desde, sw = true)
    formato = '%d-%m-%Y'
    if sw == true
      params[nombre] = params[nombre].present? ? params[nombre] : Date.today.strftime(formato)
    end
    fecha = Date.strptime(params[nombre], formato) if params[nombre].present?
    fecha
  end

  # Permite convertir un rango de fechas de String a Date
  def get_fechas(params, sw = true)
    formato = '%d-%m-%Y'
    if sw == true
      params[:desde] = params[:desde].present? ? params[:desde] : Date.today.beginning_of_year.strftime(formato)
      params[:hasta] = params[:hasta].present? ? params[:hasta] : Date.today.strftime(formato)
    end
    desde = Date.strptime(params[:desde], formato).beginning_of_day if params[:desde].present?
    hasta = Date.strptime(params[:hasta], formato).end_of_day if params[:hasta].present?
    [desde, hasta]
  end

  def generar_reporte(transacciones)
    transacciones
  end

  def cantidad_entrada(cantidad)
    cantidad >= 0 ? cantidad : 0
  end

  def cantidad_salida(cantidad)
    cantidad < 0 ? -1 * cantidad : 0
  end
end
