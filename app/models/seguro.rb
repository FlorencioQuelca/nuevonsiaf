class Seguro < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include AASM

  default_scope -> { where(baja_logica: false) }
  scope :activos, -> { where.not(baja_logica: nil) }

  belongs_to :user, dependent: :destroy
  belongs_to :supplier, dependent: :destroy
  has_and_belongs_to_many :assets
  has_many :incorporaciones, class_name: 'Seguro',
                             foreign_key: 'seguro_id'
  belongs_to :seguro, class_name: 'Seguro'

  validates :user_id, presence: true

  # validates :supplier_id, :user_id, :factura_numero, :factura_autorizacion,
  #           :factura_fecha, :fecha_inicio_vigencia, :fecha_fin_vigencia,
  #           presence: true


  aasm column: :state do
    state :cotizado, initial: true
    state :asegurado

    event :asegurar do
      transitions from: :cotizado, to: :asegurado
    end
  end

  def proveedor_nombre
    supplier.present? ? supplier.name : ''
  end

  def proveedor_nit
    supplier.present? ? supplier.nit : ''
  end

  def proveedor_telefono
    supplier.present? ? supplier.telefono : ''
  end

  def usuario_nombre
    user.present? ? user.name : ''
  end

  def vigente?(fecha_actual = DateTime.now)
    if fecha_inicio_vigencia.present? && fecha_fin_vigencia.present?
      fecha_inicio_vigencia <= fecha_actual && fecha_fin_vigencia >= fecha_actual
    else
      false
    end
  end

  def estado
    cotizado? ? "COTIZACION" : vigente? ? "VIGENTE" : "NO VIGENTE"
  end

  def cantidad_activos
    seguros_ids = [self.id] + self.incorporaciones.pluck(:id)
    "#{Asset.joins(:seguros).where(seguros: {id: seguros_ids}).uniq.size}"
  end

  # Obtiene los seguros vigentes no se toman en cuentas las incorporaciones.
  def self.vigentes(fecha_actual = DateTime.now)
    activos.where(state: 'asegurado')
           .where('fecha_inicio_vigencia <= ?', fecha_actual)
           .where('fecha_fin_vigencia >= ?', fecha_actual)
  end

  # Obtiene todo los seguros vigentes incluyendo las incorporaciones
  def self.vigentes_incorporaciones(fecha_actual = DateTime.now)
    vigentes(fecha_actual).or(activos.where(state: 'asegurado')
                                     .where(seguro_id: vigentes.ids))
  end

  def expiracion_a_dias(nro_dias)
    fecha_inicio_alerta = fecha_fin_vigencia - nro_dias
    Date.today >= fecha_inicio_alerta
  end

  def alerta_expiracion(fecha_actual=DateTime.now)
    respuesta =   {
      mensaje: "El seguro vence el #{I18n.localize fecha_fin_vigencia, format: :customize}.",
      tipo: "success",
      parpadeo: false
    }
    fin_vigencia = fecha_fin_vigencia
    inicio_vigencia = fin_vigencia - 7.days
    if fecha_actual >= inicio_vigencia && fecha_actual <= fin_vigencia
      respuesta[:parpadeo] = true
      respuesta[:tipo] = "danger"
      return respuesta
    end
    inicio_vigencia = fin_vigencia - 30.days
    if fecha_actual >= inicio_vigencia && fecha_actual <= fin_vigencia
      respuesta[:tipo] = "danger"
      return respuesta
    end
    inicio_vigencia = fin_vigencia - 90.days
    if fecha_actual >= inicio_vigencia && fecha_actual <= fin_vigencia
      respuesta[:tipo] = "warning"
      return respuesta
    end
    respuesta
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    orden = "#{sort_column} #{sort_direction}"
    array = joins("LEFT JOIN suppliers ON seguros.supplier_id = suppliers.id").where(seguro_id: nil).order(orden)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == "suppliers" ? "#{search_column}.name" : "seguros.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("seguros.numero_contrato LIKE ?", "%#{sSearch}%")
                     .or(array.where("seguros.factura_numero LIKE ?", "%#{sSearch}%"))
                     .or(array.where("suppliers.name LIKE ?", "%#{sSearch}%"))
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'numero_contrato'), h.get_column(self, 'factura_numero'), h.get_column(self, 'suppliers')]
  end

  def self.to_csv(is_low = false)
    columns_title = %w(numero_contrato suppliers numero_factura fecha_inicio_vigencia fecha_fin_vigencia estado nro_activos )
    CSV.generate do |csv|
      csv << columns_title.map { |c| self.human_attribute_name(c) }
      all.each do |seguro|
        a = []
        a.push(seguro.numero_contrato)
        a.push(seguro.proveedor_nombre)
        a.push(seguro.factura_numero)
        a.push(seguro.fecha_inicio_vigencia.present? ? I18n.l(seguro.fecha_inicio_vigencia) : '')
        a.push(seguro.fecha_fin_vigencia.present? ? I18n.l(seguro.fecha_fin_vigencia) : '')
        a.push(seguro.estado)
        a.push(seguro.cantidad_activos)
        csv << a
      end
    end
  end

  def incorporaciones_json
    respuesta = []
    incorporaciones.order(state: :desc, created_at: :desc).each do |inc|
      activos_ids = inc.assets.try(:ids)
      activos = Asset.todos.where(id: activos_ids).order(:code)
      sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
      resumen = activos.select("accounts.name as nombre, count(accounts.name) as cantidad, sum(assets.precio) as sumatoria")
                       .group("accounts.name").order("nombre")
      sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
      respuesta << {
        titulo: 'Incorporación',
        seguro: SeguroSerializer.new(inc),
        activos: ActiveModel::ArraySerializer.new(activos, each_serializer: AssetSerializer),
        sumatoria: sumatoria,
        resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
        sumatoria_resumen: sumatoria_resumen,
        urls: {
          asegurar: asegurar_seguro_url(inc),
          activos: activos_seguro_url(inc, format: :pdf),
          resumen: resumen_seguro_url(inc, format: :pdf)
        }
      }
    end
    respuesta
  end

  def activos_sin_seguro
    seguros_ids = [self.id] + self.incorporaciones.pluck(:id)
    activos_ids = Asset.joins(:seguros).where(seguros: {id: seguros_ids}).ids
    Asset.todos.where.not(id: activos_ids).order(:code)
  end
end
