
class Account < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus
  include Moneda

  CORRELATIONS = {
    'CODCONT' => 'code',
    'NOMBRE' => 'name',
    'VIDAUTIL' => 'vida_util',
    'DEPRECIAR' => 'depreciar',
    'ACTUALIZAR' => 'actualizar'
  }

  validates :code, presence: true, uniqueness: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true
  validates :vida_util, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  # Listado los que se encuentran activos
  scope :activo, -> { where(status: '1') }

  has_many :auxiliaries
  has_many :assets

  has_paper_trail

  # Lista de activos de una cuenta
  def self.activos
    Asset.joins(auxiliary: :account)
         .where(accounts: {id: ids})
         .uniq
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("code LIKE ? OR name LIKE ? OR vida_util LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code name vida_util, status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |account|
        a = account.attributes.values_at(*columns)
        a.pop(2)
        a.push(account.vida_util, h.type_status(account.status))
        csv << a
      end
    end
  end

  def self.con_activos
    joins(auxiliaries: :assets).uniq
  end

  def code_and_name
    "#{code} - #{name}"
  end

  def verify_assignment
    auxiliaries.present?
  end

  ##
  # BEGIN datos para el reporte resumen de activos fijos ordenado por grupo contable
  def auxiliares_activos(desde = Date.today, hasta = Date.today)
    activos_bajas_ids = Asset.bajas.where(bajas: {fecha: desde..hasta}).ids
    Asset.joins(:ingreso)
         .where(auxiliary_id: auxiliaries.ids)
         .where(ingresos: {factura_fecha: desde..hasta})
         .where.not(id: activos_bajas_ids)
  end

  # Lista de activos dados de baja en la cuenta en un rango de fechas
  def auxiliares_activos_bajas(desde = Date.today, hasta = Date.today)
    Asset.joins(:baja)
         .where(auxiliary_id: auxiliaries.ids)
         .where(bajas: {fecha: desde..hasta})
  end

  def cantidad_activos(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).length
  end

  def costo_historico(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).costo_historico
  end

  def costo_actualizado_inicial(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).costo_actualizado_inicial(hasta)
  end

  def depreciacion_acumulada_inicial(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).depreciacion_acumulada_inicial(hasta)
  end

  def valor_neto_inicial(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).inject(0) do |suma, activo|
      suma + activo.costo_actualizado_inicial(hasta) - activo.depreciacion_acumulada_inicial(hasta)
    end
  end

  def actualizacion_gestion(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).actualizacion_gestion(hasta)
  end

  def costo_actualizado(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).costo_actualizado(hasta)
  end

  def depreciacion_gestion(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).depreciacion_gestion(hasta)
  end

  def actualizacion_depreciacion_acumulada(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).actualizacion_depreciacion_acumulada(hasta)
  end

  def depreciacion_acumulada_total(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).depreciacion_acumulada_total(hasta)
  end

  def valor_neto(desde = Date.today, hasta = Date.today)
    auxiliares_activos(desde, hasta).valor_neto(hasta)
  end

  def self.cantidad_activos(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + cuenta.cantidad_activos(desde, hasta)
    end
  end

  def self.costo_historico(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_historico(desde, hasta))
    end
  end

  def self.costo_actualizado_inicial(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_actualizado_inicial(desde, hasta))
    end
  end

  def self.depreciacion_acumulada_inicial(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_acumulada_inicial(desde, hasta))
    end
  end

  def self.valor_neto_inicial(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.valor_neto_inicial(desde, hasta))
    end
  end

  def self.actualizacion_gestion(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.actualizacion_gestion(desde, hasta))
    end
  end

  def self.costo_actualizado(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.costo_actualizado(desde, hasta))
    end
  end

  def self.depreciacion_gestion(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_gestion(desde, hasta))
    end
  end

  def self.actualizacion_depreciacion_acumulada(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.actualizacion_depreciacion_acumulada(desde, hasta))
    end
  end

  def self.depreciacion_acumulada_total(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.depreciacion_acumulada_total(desde, hasta))
    end
  end

  def self.valor_neto(desde = Date.today, hasta = Date.today)
    all.inject(0) do |suma, cuenta|
      suma + redondear(cuenta.valor_neto(desde, hasta))
    end
  end
  # END datos para el reporte resumen de activos fijos ordenado por grupo contable
  ##
  #
  ##

  def retorna_auxiliares
    auxiliaries.select('auxiliaries.id,auxiliaries.code, auxiliaries.name, count(assets.id) as cantidad_activos , sum(assets.precio) as monto_activos')
               .joins(:assets)
               .group('auxiliaries.id')
               .order('auxiliaries.code')

  end

  def retorna_activos
    auxiliaries.select('assets.id, assets.code, assets.description, auxiliaries.name, assets.precio')
               .joins(:assets)
               .order('assets.code')
  end

  def self.resumen_activos_ods(desde, hasta, accounts)
    headers = [
      ['No','Grupo Contable','Cantidad', 'Vida Útil', 'Costo Histórico', 'Costo Actualización Inicial', 'Depreciación Acumulado Total de Grupo', 'Valor Neto Inicial', 'Actualización Gestión', 'Costo Total Actualizado', 'Depreciación Gestión', 'Actualización Depreciación Acumulado', 'Depreciación Acumulada', 'Valor Neto']
    ]
    data = []
    accounts.each_with_index do |cuenta, index|
      data  << [
                  index + 1,
                  cuenta.name,
                  cuenta.cantidad_activos(desde, hasta),
                  cuenta.vida_util,
                  cuenta.costo_historico(desde, hasta),
                  cuenta.costo_actualizado_inicial(desde, hasta),
                  cuenta.depreciacion_acumulada_inicial(desde, hasta),
                  cuenta.valor_neto_inicial(desde, hasta),
                  cuenta.actualizacion_gestion(desde, hasta),
                  cuenta.costo_actualizado(desde, hasta),
                  cuenta.depreciacion_gestion(desde, hasta),
                  cuenta.actualizacion_depreciacion_acumulada(desde, hasta),
                  cuenta.depreciacion_acumulada_total(desde, hasta),
                  cuenta.valor_neto(desde, hasta)
                 ]
    end
    data <<[
      '',
      'TOTALES',
      accounts.cantidad_activos(desde, hasta),
      '',
      accounts.costo_historico(desde, hasta),
      accounts.costo_actualizado_inicial(desde, hasta),
      accounts.depreciacion_acumulada_inicial(desde, hasta),
      accounts.valor_neto_inicial(desde, hasta),
      accounts.actualizacion_gestion(desde, hasta),
      accounts.costo_actualizado(desde, hasta),
      accounts.depreciacion_gestion(desde, hasta),
      accounts.actualizacion_depreciacion_acumulada(desde, hasta),
      accounts.depreciacion_acumulada_total(desde, hasta),
      accounts.valor_neto(desde, hasta)
    ]
    {
      headers: headers,
      data: data
    }
  end

  def self.depreciacion_activos_ods(desde, hasta, cuentas)
    fecha = hasta
    headers =[
      ['No', 'Código', 'Descripción','Fecha Histórico', 'Revalúo Inicial', 'Índice UFV', 'Costo Histórico', 'Costo Actualizado Inicial', 'Depreciación Acumulada Inicial', 'Vida Útil Residual Nominal', 'Factor de actualización', 'Actualización de gestión', 'Costo actualizado', 'Porcentaje de depreciación anual', 'Días consumidos', 'Depreciación de la gestión', 'Actualización depreciación acumulada', 'Depreciación Acumulada Total', 'Valor Neto', 'Dar Revalúo o Baja']
    ]
    data = []
    cuentas.each_with_index do |cuenta, index|
      activos = cuenta.auxiliares_activos(desde, fecha)
      if activos.size > 0
        data  << [
          '',
          '',
          "GRUPO CONTABLE: #{cuenta.name}",
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          ''
         ]
      end
      activos.each_with_index do |activo, index|
        data  << [
          index + 1,
          activo.code,
          activo.description,
          (I18n.l(activo.ingreso_fecha) if activo.ingreso_fecha),
          activo.revaluo_inicial,
          ('%.5f' % activo.indice_ufv).to_f, 
          ('%.2f' % activo.costo_historico).to_f,
          ('%.2f' % activo.costo_actualizado_inicial(fecha)).to_f,
          ('%.2f' % activo.depreciacion_acumulada_inicial(fecha)).to_f,
          activo.vida_util_residual_nominal,
          ('%.6f' % activo.factor_actualizacion(fecha)).to_f,
          ('%.2f' % activo.actualizacion_gestion(fecha)).to_f,
          ('%.2f' % activo.costo_actualizado(fecha)).to_f,
          ('%.2f' % activo.porcentaje_depreciacion_anual).to_f,
          "#{activo.dias_consumidos(fecha)} #{activo.dias_consumidos_ultimo(fecha)}",
          ('%.2f' % activo.depreciacion_gestion(fecha)).to_f,
          ('%.2f' % activo.actualizacion_depreciacion_acumulada(fecha)).to_f,
          ('%.2f' % activo.depreciacion_acumulada_total(fecha)).to_f,
          ('%.2f' % activo.valor_neto(fecha)).to_f,
          activo.dar_revaluo_o_baja
         ]
      end
      data <<[
        '',
        '',
        "CANTIDAD: #{activos.length}",
        '',
        'TOTAL DE GRUPO:',
        '',
        ('%.2f' % activos.costo_historico).to_f,
        ('%.2f' % activos.costo_actualizado_inicial(fecha)).to_f,
        ('%.2f' % activos.depreciacion_acumulada_inicial(fecha)).to_f,
        '',
        '',
        ('%.2f' % activos.actualizacion_gestion(fecha)).to_f,
        ('%.2f' % activos.costo_actualizado(fecha)).to_f,
        '',
        '',
        ('%.2f' % activos.depreciacion_gestion(fecha)).to_f,
        ('%.2f' % activos.actualizacion_depreciacion_acumulada(fecha)).to_f,
        ('%.2f' % activos.depreciacion_acumulada_total(fecha)).to_f,
        ('%.2f' % activos.valor_neto(fecha)).to_f,
        ''
      ]
    end
    data <<[
      '',
      '',
      "CANTIDAD DE ACTIVOS: #{cuentas.cantidad_activos(desde, fecha)}",
      '',
      'TOTALES:',
      '',
      ('%.2f' % cuentas.costo_historico(desde, fecha)).to_f,
      ('%.2f' % cuentas.costo_actualizado_inicial(desde, fecha)).to_f,
      ('%.2f' % cuentas.depreciacion_acumulada_inicial(desde, fecha)).to_f,
      '',
      '',
      ('%.2f' % cuentas.actualizacion_gestion(desde, fecha)).to_f,
      ('%.2f' % cuentas.costo_actualizado(desde, fecha)).to_f,
      '',
      '',
      ('%.2f' % cuentas.depreciacion_gestion(desde, fecha)).to_f,
      ('%.2f' % cuentas.actualizacion_depreciacion_acumulada(desde, fecha)).to_f,
      ('%.2f' % cuentas.depreciacion_acumulada_total(desde, fecha)).to_f,
      ('%.2f' % cuentas.valor_neto(desde, fecha)).to_f,
      ''
    ]
    {
      headers: headers,
      data: data
    }
  end

  def self.bajas_ods(desde, hasta, cuentas)
    fecha = hasta
    headers =[
      ['No', 'Código', 'Descripción','Fecha Histórico', 'Costo Histórico', 'Costo Actual Inicial', 'Depreciación Acumulada Inicial', 'Valor Neto Inicial', '', 'Vida Útil Residual Nominal', 'Fecha de Baja', 'Índice UFV', 'UFV Baja o Vida Útil', 'Facto de actualización', 'Costo total actualizado', 'Porcentaje de depreciación anual', 'Días consumidos', 'Depreciación de la gestión', 'Depreciación Acumulada Total', 'Valor Neto']
    ]
    data = []
    cuentas.each_with_index do |cuenta, indice|
      activos = cuenta.auxiliares_activos_bajas(desde, fecha)
      if activos.size > 0
        data  << [
          '',
          '',
          "GRUPO CONTABLE: #{cuenta.name}",
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          ''
         ]
      end
      activos.each_with_index do |activo, index|
        fecha_baja = activo.baja_fecha.to_date
        data  << [
          index + 1,
          activo.code,
          activo.description,
          (I18n.l(activo.ingreso_fecha) if activo.ingreso_fecha),
          ('%.2f' % activo.precio).to_f,
          ('%.2f' % activo.costo_actualizado_inicial(fecha_baja)).to_f,
          ('%.2f' % activo.depreciacion_acumulada_inicial(fecha_baja)).to_f,
          ('%.2f' % activo.valor_neto_inicial(fecha_baja)).to_f,
          activo.vida_util_residual_nominal,
          I18n.l(fecha_baja),
          ('%.5f' % activo.indice_ufv).to_f,
          ('%.5f' % Ufv.indice(fecha_baja)).to_f,
          ('%.6f' % activo.factor_actualizacion(fecha_baja)).to_f,
          ('%.2f' % activo.costo_actualizado(fecha_baja)).to_f,
          ('%.2f' % activo.porcentaje_depreciacion_anual).to_f,
          activo.dias_consumidos(fecha_baja),
          ('%.2f' % activo.depreciacion_gestion(fecha_baja)).to_f,
          ('%.2f' % activo.depreciacion_acumulada_total(fecha_baja)).to_f,
          ('%.2f' % activo.valor_neto(fecha_baja)).to_f,
         ]
      end
      data <<[
        '',
        '',
        "CANTIDAD: #{activos.length}",
        'TOTAL DE GRUPO:',
        ('%.2f' % activos.total_historico).to_f,
        ('%.2f' % activos.costo_actualizado_inicial(fecha)).to_f,
        ('%.2f' % activos.depreciacion_acumulada_inicial(fecha)).to_f,
        ('%.2f' % activos.valor_neto_inicial(fecha)).to_f,
        '',
        '',
        '',
        '',
        '',
        ('%.2f' % activos.costo_actualizado(fecha)).to_f,
        '',
        '',
        ('%.2f' % activos.depreciacion_gestion(fecha)).to_f,
        ('%.2f' % activos.depreciacion_acumulada_total(fecha)).to_f,
        ('%.2f' % activos.valor_neto(fecha)).to_f,
        ''
      ]
      if cuentas.length == indice + 1
        activos_bajas = cuentas.activos.bajas.where(bajas: {fecha: desde..fecha})
        data <<[
          '',
          '',
          "CANTIDAD DE ACTIVOS: #{activos_bajas.length}",
          'TOTALES:',
          '',
          ('%.2f' % activos_bajas.total_historico).to_f,
          ('%.2f' % activos_bajas.costo_actualizado_inicial(fecha)).to_f,
          ('%.2f' % activos_bajas.depreciacion_acumulada_inicial(fecha)).to_f,
          ('%.2f' % activos_bajas.valor_neto_inicial(fecha)).to_f,
          '',
          '',
          '',
          '',
          '',
          ('%.2f' % activos_bajas.costo_actualizado(fecha)).to_f,
          '',
          '',
          ('%.2f' % activos_bajas.depreciacion_gestion(fecha)).to_f,
          ('%.2f' % activos_bajas.depreciacion_acumulada_total(fecha)).to_f,
          ('%.2f' % activos_bajas.valor_neto(fecha)).to_f,
          ''
        ]
      end
    end
    {
      headers: headers,
      data: data
    }
  end
end
