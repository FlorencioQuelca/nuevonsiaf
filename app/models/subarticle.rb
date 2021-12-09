class Subarticle < ActiveRecord::Base
  include Migrated, ManageStatus, VersionLog
  include Autoincremento
  include CodeNumber
  include EjecutarSQL

  belongs_to :material
  has_many :subarticle_requests
  has_many :requests, through: :subarticle_requests
  has_many :entry_subarticles
  has_many :transacciones, :class_name => "Transaccion", :foreign_key => "subarticle_id"

  with_options if: :is_not_migrate? do |m|
    m.validates :material_id, presence: true
    m.validates :barcode, presence: true, uniqueness: true
    m.validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :description, :unit, presence: true
    m.validates :incremento, presence: true, uniqueness: { scope: :material_id, message: "debe ser único por material" }
    #m.validates :amount, :minimum, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    #
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, :unit, presence: true
  end

  has_paper_trail

  def self.active
    where(status: '1')
  end

  # Selecciona aquellos subartículos con saldo mayor a cero
  # o que tuvieron movimientos de entrada/salida en un rango de fechas
  def self.con_saldo_y_movimientos_en(desde = Date.today, hasta = Date.today)
    self.con_saldo(desde)
        .union(con_movimientos_en(desde, hasta))
  end

  # Lista de subartículos con movimientos de entrada/salida en un rango de fechas
  def self.con_movimientos_en(desde = Date.today, hasta = Date.today)
    self.joins(:transacciones)
        .where(entradas_salidas: {fecha: desde..hasta})
        .where("entradas_salidas.cantidad > 0")
        .where(entradas_salidas: {tipo: 'entrada'})
  end

  # Subartículos que tienen saldo hasta una fecha indicada
  def self.con_saldo(fecha = Date.today)
    self.joins(:transacciones).where('fecha <= ?', fecha)
                              .group(:id)
                              .having('SUM(cantidad) > 0')
  end

  def self.estado_activo
    self.active
  end

  # Suma el importe total para cada grupo de materiales
  def self.total(hasta = Date.today)
    all.inject(0) do |suma, subarticle|
      f_kardex = subarticle.saldo_final(hasta)
      suma + f_kardex.items.sum(&:importe_saldo)
    end
  end

  # Decrementar el stock del subartículo
  def entregar_subarticulo(cantidad)
    cantidad_solicitada = cantidad
    if stock >= cantidad_solicitada
      while cantidad_solicitada > 0
        if stock >= cantidad_solicitada
          entry_subarticle = entry_subarticles_exist.first
          raise ActiveRecord::Rollback unless entry_subarticle.present?
          stock_entry_subarticle = entry_subarticle.stock
          if stock_entry_subarticle >= cantidad_solicitada
            entry_subarticle.decrementando_stock(cantidad_solicitada)
            cantidad_solicitada = 0
          else
            entry_subarticle.decrementando_stock(stock_entry_subarticle)
            cantidad_solicitada -= stock_entry_subarticle
          end
        end
      end
    else
      raise ActiveRecord::Rollback
    end
  end

  ##
  # Obtiene un reporte en un rango de fechas dado. Adiciona el saldo a la fecha
  # seleccionada
  def reporte(desde, hasta)
    _transacciones = transacciones.saldo_al(desde)
    transacciones.where(fecha: ((desde+1)..hasta)).each do |t|
      _transacciones.push(t)
    end
    _transacciones
  end

  def kardexs(desde, hasta)
    _transacciones = transacciones.where(fecha: ((desde+1)..hasta))

    fechas = _transacciones.map { |t| t.fecha }.uniq

    lista = []
    fechas.each do |fecha|
      elegidos = _transacciones.where(fecha: fecha)
      saldos = transacciones.saldo_al(fecha - 1)
      elegidos.each do |transaccion|
        # transaccion.detalle += "- #{saldos.map(&:cantidad_saldo)}"
        saldos = transaccion.crear_items(saldos)
        # transaccion.detalle += "- #{saldos.map(&:cantidad_saldo)},  #{transaccion.cantidad}"
        lista << transaccion
      end
    end

    # Saldo Inicial
    saldo_inicial = transacciones.saldo_inicial(desde)

    # Saldo Final
    saldo_final = transacciones.saldo_final_resumen(hasta)

    lista = if !transacciones.first.nil? and desde < transacciones.first.fecha
              lista + [saldo_final]
            else
              [saldo_inicial] + lista + [saldo_final]
            end

    # Sumar saldo final
    Transaccion.generar_saldo_final(lista)

    lista
  end

  def self.minimum_stock(weight = 1.25)
    with_stock.select do |subarticle|
      subarticle.stock <= subarticle.minimum.to_i * weight
    end
  end

  def article_code
    article.present? ? article.code : ''
  end

  def article_name
    article.present? ? article.description : ''
  end

  def saldo_inicial(fecha = Date.today)
    transacciones.saldo_inicial(fecha)
  end

  def saldo_final(fecha = Date.today)
    transacciones.saldo_final(fecha)
  end

  def verify_assignment
    false
  end

  def stock
    # entry_subarticles_exist.sum(:stock)
    transacciones.sum(:cantidad)
  end

  def saldo(fecha = Date.today)
    lista = transacciones.where('fecha < ?', fecha)
    if lista.count.zero?
      transacciones.first.present? ? transacciones.first.cantidad : 0
    else
      lista.sum(:cantidad)
    end
  end

  # Only entries with stock > 0
  def entry_subarticles_exist(year = Date.today.year)
    # s_date = Date.strptime(year.to_s, '%Y').beginning_of_day
    # e_date = s_date.end_of_year.end_of_day
    # TODO la validación tiene que verificar si la gestión ha sido cerrada
    # caso contrario no se aplica ninguna verificación.
    #
    # entry_subarticles.search(stock_gt: 0,
    #                          date_gteq: s_date,
    #                          date_lteq: e_date).result(distinct: true)

    entry_subarticles.search(stock_gt: 0).result(distinct: true)
  end

  ##
  # Código del material al cual pertenece los subartículos
  def material_code
    if material.present?
      material.code
    else
      ''
    end
  end

  ##
  # Descripción de model material asociado al subartículo
  def material_description
    material.present? ? material.description : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'code_old'), h.get_column(self, 'description'), h.get_column(self, 'unit'), h.get_column(self, 'material')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:material).order("#{sort_column} #{sort_direction}").references(:material)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      h = ApplicationController.helpers
      sSearch = h.changeBarcode(sSearch)
      if search_column.present?
        type_search = search_column == 'material' ? 'materials.description' : "subarticles.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("subarticles.code LIKE ? OR subarticles.code_old LIKE ? OR subarticles.description LIKE ? OR subarticles.unit LIKE ? OR materials.description LIKE ? OR subarticles.barcode LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code codel_old description unit material status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |subarticle|
        a = subarticle.attributes.values_at(*columns)
        a.pop(2)
        a.push(subarticle.material_description, h.type_status(subarticle.status))
        csv << a
      end
    end
  end

  def self.get_barcode(barcode)
    where(barcode: barcode)
  end

  def self.is_closed_year?(year = Date.today.year)
    with_stock(year).count == 0
  end

  def self.with_stock(year = Date.today.year)
    s_date = Date.strptime(year.to_s, '%Y').beginning_of_day
    e_date = s_date.end_of_year.end_of_day
    search(
      entry_subarticles_stock_gt: 0,
      entry_subarticles_date_gteq: s_date,
      entry_subarticles_date_lteq: e_date).result(distinct: true)
  end

  def exists_amount?
    # entry_subarticles_exist.present?
    transacciones.sum(:cantidad) > 0
  end

  def decrease_amount
    if entry_subarticles_exist.length > 0
      entry_subarticle = entry_subarticles_exist.first # FIFO - PEPS
      entry_subarticle.decrease_amount
    end
  end

  def self.search_subarticle(q)
    h = ApplicationController.helpers
    q = h.changeBarcode(q)
    all.ransack({code_or_code_old_or_description_or_barcode_cont: q, status_eq: 1}).result
      .select('subarticles.id, subarticles.description, subarticles.unit, subarticles.code, sum(entradas_salidas.cantidad) as cantidad_total')
      .joins('LEFT JOIN entradas_salidas ON entradas_salidas.subarticle_id = subarticles.id')
      .group('subarticles.id, subarticles.description, subarticles.unit, subarticles.code')
      .map {|s| {id: s.id, code: s.code, description: s.description, unit: s.unit, stock: s.cantidad_total, existencia: (s.cantidad_total.present? ? !s.cantidad_total.zero? : false)}}
  end

  # servicio para plantillas
  def self.buscar_articulo(q, todos = false)
    h = ApplicationController.helpers
    q = h.changeBarcode(q)
    articulos = all.ransack({code_or_code_old_or_description_or_barcode_cont: q, status_eq: 1}).result
      .select('subarticles.id, subarticles.description, subarticles.unit, subarticles.code, sum(entradas_salidas.cantidad) as cantidad_total, materials.description grupo_contable')
      .joins('INNER JOIN materials ON materials.id = subarticles.material_id')
      .joins('LEFT JOIN entradas_salidas ON entradas_salidas.subarticle_id = subarticles.id')
      .group('subarticles.id, subarticles.description, subarticles.unit, subarticles.code')

    if !todos
      articulos = articulos.having('cantidad_total > 0')
    end
    articulos.map {|s| {id: s.id, codigo: s.code, descripcion: s.description, unidad: s.unit, cuenta: s.grupo_contable}}
  end

  def esta_activo?
    status == '1'
  end

  def self.search_by(article_id)
    subarticles = []
    subarticles = where(article_id: article_id, status: 1) if article_id.present?
    [['', '--']] + subarticles.map { |d| [d.id, d.description] }
  end

  # Update stock=0 for all entry_subarticles
  def close_stock!(year = Date.today.year)
    entry_subarticles_exist(year).update_all(stock: 0, updated_at: Time.now)
  end

  def valorado_ingresos(desde, hasta)
    _transacciones = reporte(desde, hasta)
    _transacciones.inject(0) do |suma, transaccion|
      if transaccion.tipo == 'entrada'
        suma + (transaccion.cantidad * transaccion.costo_unitario)
      else
        suma
      end
    end
  end

  def valorado_salidas(desde, hasta)
    _transacciones = reporte(desde, hasta)
    _transacciones.inject(0) do |suma, transaccion|
      if transaccion.tipo == 'salida'
        suma + (-transaccion.cantidad * transaccion.precio_unitario)
      else
        suma
      end
    end
  end

  def valorado_saldo(desde, hasta)
    valorado_ingresos(desde, hasta) - valorado_salidas(desde, hasta)
  end

  def obtiene_kardex_v2(desde, hasta)
    resultado = ejecutar_sql("call genera_kardex_v2(#{ id }, '#{ desde.strftime('%Y-%m-%d %H:%M:%S') }', '#{ hasta.strftime('%Y-%m-%d %H:%M:%S') }');")
    ActiveRecord::Base.clear_active_connections!
    {
      datos: resultado,
      sumatoria_cantidad_ingreso: resultado.inject(0) { |sum, x| sum + x["cantidad_ingreso"] },
      sumatoria_cantidad_egreso: resultado.inject(0) { |sum, x| sum + x["cantidad_egreso"] },
      saldo_final_cantidad: (resultado.last["cantidad_saldo"] rescue 0),
      sumatoria_importe_ingreso: resultado.inject(0) { |sum, x| sum + x["importe_ingreso"] },
      sumatoria_importe_egreso: resultado.inject(0) { |sum, x| sum + x["importe_egreso"] },
      saldo_final_importe: (resultado.last["importe_saldo"] rescue 0)
    }
  end

  def formato_ods(datos)
    headers = [
      ['factura', 'nro pedido', 'cite', 'operación', 'fecha', 'detalle', 'precio unitario', 'ingreso cantidad', 'egreso cantidad', 'saldo cantidad', 'ingreso importe', 'egreso importe', 'saldo importe']
    ]
    data = []
    datos[:datos].each do |fila|
      data  << [
        fila["factura"],
        fila["nro_pedido"],
        fila["cite_ems_plantillas"],
        fila["tipo"],
        fila["fecha"],
        fila["detalle"],
        fila["costo_unitario"].to_f,
        fila["cantidad_ingreso"].to_f,
        fila["cantidad_egreso"].to_f,
        fila["cantidad_saldo"].to_f,
        fila["importe_ingreso"].to_f,
        fila["importe_egreso"].to_f,
        fila["importe_saldo"].to_f,
      ]
    end
    data <<[
      '',
      '',
      '',
      'SALDO FINAL',
      '',
      '',
      '',
      datos[:sumatoria_cantidad_ingreso].to_f,
      datos[:sumatoria_cantidad_egreso].to_f,
      datos[:saldo_final_cantidad].to_f,
      datos[:sumatoria_importe_ingreso].to_f,
      datos[:sumatoria_importe_egreso].to_f,
      datos[:saldo_final_importe].to_f
    ]
    {
      headers: headers,
      data: data
    }
  end
end
