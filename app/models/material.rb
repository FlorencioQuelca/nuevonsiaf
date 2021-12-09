class Material < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  include ManageStatus
  include EjecutarSQL

  scope :activos, -> { where(status: '1') }
  scope :con_subarticulos, -> { joins(:subarticles).where('subarticles.status = 1').uniq }

  has_many :subarticles

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, presence: true

  has_paper_trail

  def detalle
    "#{code} - #{description}"
  end

  def valorado_ingresos(desde, hasta)
    subarticles.inject(0) do |total, article|
      total + article.valorado_ingresos(desde, hasta)
    end
  end

  def valorado_salidas(desde, hasta)
    subarticles.inject(0) do |total, article|
      total + article.valorado_salidas(desde, hasta)
    end
  end

  def valorado_saldo(desde, hasta)
    subarticles.inject(0) do |total, article|
      total + article.valorado_saldo(desde, hasta)
    end
  end

  def verify_assignment
    subarticles.present?
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'description')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("code LIKE ? OR description LIKE ?", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.cuenta_contable(fecha)
    ejecutar_sql(
      sanitize_sql(
        [cuenta_contable_sql, {hasta_fecha: fecha}]
      )
    )
  end

  def self.cuenta_contable_total(fecha)
    ejecutar_sql(
      sanitize_sql(
        [cuenta_contable_total_sql, {hasta_fecha: fecha}]
      )
    )
  end

  def self.to_csv
    columns = %w(code description status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |product|
        a = product.attributes.values_at(*columns)
        a.pop(1)
        a.push(h.type_status(product.status))
        csv << a
      end
    end
  end

  def subarticulos_fisico_valorado(desde, hasta)
    matriz_fisico_valorado= []
    total = subarticles.estado_activo.total(hasta)
    self.subarticles.estado_activo.each do |subarticulo|
      i_kardex = subarticulo.saldo_inicial(desde)
      f_kardex = subarticulo.saldo_final(hasta)
      kp = f_kardex.items.length
      datos_ingreso = []
      i_kardex.items.each_with_index do |p, i|
        datos_ingreso << { cantidad_saldo: mostrar_entero_float(p.cantidad_saldo), costo_unitario: number_with_delimiter(p.costo_unitario) }
      end
      Transaccion.suma_entradas(f_kardex.items, desde, hasta)
      Transaccion.suma_salidas(f_kardex.items, desde, hasta)
      f_kardex.items.each_with_index do |price, index|
        material = matriz_fisico_valorado.select{ |s| s[:codigo] == subarticulo.code }.first
        if material.present?
          material[:mas_registros] << {
            cantidad_entrada: mostrar_entero_float(price.cantidad_entrada),
            costo_unitario_entrada: number_with_delimiter(price.cantidad_entrada > 0 ? price.costo_unitario : 0),
            cantidad_salida: mostrar_entero_float(price.cantidad_salida),
            cantidad_saldo: mostrar_entero_float(price.cantidad_saldo),
            costo_unitario: number_with_delimiter(price.costo_unitario),
            importe_saldo: number_with_delimiter(price.importe_saldo)
          }
        else
          registro_en_cero = (kp == 1 && datos_ingreso.length == 1 &&
            datos_ingreso.first[:cantidad_saldo] == 0 && price.cantidad_entrada == 0 &&
            price.cantidad_entrada == 0 && price.cantidad_salida == 0 &&
            price.cantidad_saldo == 0 && price.costo_unitario == 0 && price.importe_saldo == 0)
            registro = {
            codigo_material: self.code,
            codigo: subarticulo.code,
            descripcion: subarticulo.description,
            unidad: (subarticulo.unit.present? ? subarticulo.unit : '').upcase,
            cantidad_items: kp,
            datos_ingreso: datos_ingreso,
            cantidad_entrada: mostrar_entero_float(price.cantidad_entrada),
            costo_unitario_entrada: number_with_delimiter(price.cantidad_entrada > 0 ? price.costo_unitario : 0),
            cantidad_salida: mostrar_entero_float(price.cantidad_salida),
            cantidad_saldo: mostrar_entero_float(price.cantidad_saldo),
            costo_unitario: number_with_delimiter(price.costo_unitario),
            importe_saldo: number_with_delimiter(price.importe_saldo),
            mas_registros: []
          }
          if registro_en_cero
            registro[:registro_en_cero] = registro_en_cero
          end
          matriz_fisico_valorado << registro
        end
      end
    end
    {
      subarticulos: matriz_fisico_valorado,
      total: number_with_delimiter(total)
    }
  end

  private

  def self.cuenta_contable_sql
    """
    SELECT m1.*, CAST(m1.ingresos_bs - m2.saldo_bs AS DECIMAL(10, 2)) AS salidas_bs, m2.saldo_bs
    FROM (SELECT m.*, SUM(CAST(es.unit_cost * es.amount AS DECIMAL(10, 2))) ingresos_bs
      FROM materials m
        INNER JOIN subarticles s ON m.id = s.material_id
        INNER JOIN entry_subarticles es ON s.id = es.subarticle_id
      WHERE es.invalidate = 0 AND es.date <= :hasta_fecha
      GROUP BY m.id) m1
      INNER JOIN (SELECT m.*, SUM(total_saldo_bs(s.id, :hasta_fecha)) saldo_bs
        FROM materials m
          LEFT JOIN subarticles s ON s.material_id = m.id
        WHERE m.status = '1'
        GROUP BY m.id) m2 ON m1.id = m2.id
    ORDER BY m1.code
    """
  end

  def self.cuenta_contable_total_sql
    """
    SELECT
      SUM(m3.ingresos_bs) AS total_ingresos_bs,
      SUM(m3.salidas_bs) AS total_salidas_bs,
      SUM(m3.saldo_bs) AS total_saldo_bs
    FROM (
      #{cuenta_contable_sql}
    ) m3
    """
  end

  def self.reporte_fisico_valorado(cuenta_ids, fecha_inicio, fecha_fin, ceros)
    datos = fisico_valorado(cuenta_ids, fecha_inicio, fecha_fin, ceros)
    nuevos_datos = [] 
    total_valorado_inicial = 0
    total_valorado_ingreso = 0
    total_valorado_egreso = 0
    total_valorado_final = 0

    datos.map { |e| e["code_material"]}.uniq.each do |cod_material|
      sumatoria_fisico_inicial = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["fisico_inicial"]}
      sumatoria_fisico_ingreso = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["fisico_ingreso"]}
      sumatoria_fisico_egreso = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["fisico_egreso"]}
      sumatoria_fisico_final = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["fisico_final"]}
      sumatoria_valorado_inicial = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["valorado_inicial"]}
      sumatoria_valorado_ingreso = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["valorado_ingreso"]}
      sumatoria_valorado_egreso = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["valorado_egreso"]}
      sumatoria_valorado_final = datos.select {|e| e["code_material"] == cod_material }.inject(0) {|sum, x| sum + x["valorado_final"]}
      total_valorado_inicial += sumatoria_valorado_inicial 
      total_valorado_ingreso += sumatoria_valorado_ingreso 
      total_valorado_egreso += sumatoria_valorado_egreso 
      total_valorado_final += sumatoria_valorado_final

      nuevos_datos << {
        "code_material": cod_material,
        "description": datos.select {|e| e["code_material"] == cod_material }.first["description_material"],
        "fisico_inicial": sumatoria_fisico_inicial,
        "fisico_ingreso": sumatoria_fisico_ingreso,
        "fisico_egreso": sumatoria_fisico_egreso,
        "fisico_final": sumatoria_fisico_final,
        "valorado_inicial": sumatoria_valorado_inicial,
        "valorado_ingreso": sumatoria_valorado_ingreso,
        "valorado_egreso": sumatoria_valorado_egreso,
        "valorado_final": sumatoria_valorado_final,
        "grupo": true
      }
      nuevos_datos += datos.select {|e| e["code_material"] == cod_material }
    end
    nuevos_datos = {
      "detalle": nuevos_datos,
      "total_valorado_inicial": total_valorado_inicial,
      "total_valorado_ingreso": total_valorado_ingreso,
      "total_valorado_egreso": total_valorado_egreso,
      "total_valorado_final": total_valorado_final
    }
    [nuevos_datos, 'ok']
  end

  def self.fisico_valorado(cuenta_ids, fecha_inicio, fecha_fin, ceros)
    ejecutar_sql(
      sanitize_sql(
          [fisico_valorado_sql(ceros.present?), { cuenta_ids: cuenta_ids, fecha_inicio: fecha_inicio, fecha_fin: fecha_fin }]
        )
      )
  end

  def self.fisico_valorado_sql(condicion)
    """
      select material_id,
             code_material,
             description_material,
             id,
             code_subarticle,
             description,
             unit,
             fisico_inicial,
             fisico_ingreso,
             fisico_egreso,
             fisico_final,
             valorado_inicial,
             valorado_ingreso,
             valorado_egreso,
             valorado_final
        from (select material_id,
                     code_material,
                     description_material,
                     id,
                     code_subarticle,
                     description,
                     unit,
                     fisico_inicial,
                     fisico_ingreso,
                     (fisico_inicial + fisico_ingreso - fisico_final) as fisico_egreso,
                     fisico_final,
                     valorado_inicial,
                     valorado_ingreso,
                     (valorado_inicial + valorado_ingreso - valorado_final) as valorado_egreso,
                     valorado_final
                from (select material_id,
                             code_material,
                             description_material,
                             id,
                             code_subarticle,
                             description,
                             unit,
                             CAST(SUBSTRING_INDEX(saldo_final_fecha_1,'|', 1) AS DECIMAL(10,2)) as fisico_inicial,
                             CAST(SUBSTRING_INDEX(total_ingresos,'|', 1) AS DECIMAL(10,2)) as fisico_ingreso,
                             CAST(SUBSTRING_INDEX(saldo_final_fecha_2,'|',1) AS DECIMAL(10,2)) as fisico_final,
                             CAST(SUBSTRING_INDEX(saldo_final_fecha_1,'|',-1) AS DECIMAL(10,2)) as valorado_inicial,
                             CAST(SUBSTRING_INDEX(total_ingresos,'|',-1) AS DECIMAL(10,2)) as valorado_ingreso,
                             CAST(SUBSTRING_INDEX(saldo_final_fecha_2,'|',-1) AS DECIMAL(10,2)) as valorado_final
                        from (select s2.material_id,
                                     m2.code as code_material,
                                     m2.description as description_material,
                                     s2.id,
                                     s2.code as code_subarticle,
                                     s2.description,
                                     s2.unit,
                                     total_ingresos_v1(s2.id, cast(concat(str_to_date(:fecha_inicio, '%d-%m-%Y'), ' 00:00:00') as datetime), cast(concat(str_to_date(:fecha_fin, '%d-%m-%Y'), ' 23:59:59') as datetime)) as total_ingresos,
                                     saldo_final_v1(s2.id, cast(concat(str_to_date(:fecha_fin, '%d-%m-%Y'), ' 23:59:59') as datetime)) as saldo_final_fecha_2,
                                     saldo_final_v1(s2.id, cast(concat(str_to_date(:fecha_inicio, '%d-%m-%Y'), ' 00:00:00') as datetime)) as saldo_final_fecha_1
                                from subarticles s2 inner join materials m2 on s2.material_id = m2.id 
                               where s2.status = 1
                                 and m2.id in (:cuenta_ids)
                                 and m2.status = 1) t1) t2
               #{ condicion ? 'where (fisico_inicial > 0 or fisico_ingreso > 0 or fisico_final > 0)' : '' }) t3
      order by code_material, code_subarticle;
    """
  end

  def self.prepara_hoja_calculo(datos, tipo)
    headers = [
      ['código','grupo contable','unidad', 'físico inicio', 'físico ingreso', 'físico egreso', 'físico final', 'valorado inicio', 'valorado ingreso', 'valorado egreso', 'valorado final']
    ]
    data = []
    datos[:detalle].each do |fila|
      if tipo == 'detalle' || (tipo == 'resumen' && fila[:grupo].present?)
        data  << [
                  !fila[:grupo].present? ? fila[:code_subarticle] : fila[:code_material],
                  fila[:description],
                  !fila[:grupo].present? ? fila[:unit].upcase : '',
                  fila[:fisico_inicial].to_f,
                  fila[:fisico_ingreso].to_f,
                  fila[:fisico_egreso].to_f,
                  fila[:fisico_final].to_f,
                  fila[:valorado_inicial].to_f,
                  fila[:valorado_ingreso].to_f,
                  fila[:valorado_egreso].to_f,
                  fila[:valorado_final].to_f
                ]
      end
    end
    data <<[
      '',
      '',
      'TOTALES',
      '',
      '',
      '',
      '',
      datos[:total_valorado_inicial].to_f,
      datos[:total_valorado_ingreso].to_f,
      datos[:total_valorado_egreso].to_f,
      datos[:total_valorado_final].to_f
    ]
    {
      headers: headers,
      data: data
    }
  end
end
