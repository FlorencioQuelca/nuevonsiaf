module StoreHelper

  def is_closed_previous_year?(year = Date.today.year-1)
    Subarticle.is_closed_year?(year)
  end

  def sumar_total_salidas(resultados, fila)
    resultados.select { |r| r['codigo'] == fila['codigo'] }
              .inject(0) { |suma, r| suma + r['cantidad'] }
  end

end
