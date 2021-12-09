class Asset < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog
  include Moneda
  include Autoincremento

  CORRELATIONS = {
    'CODIGO' => 'code_old',
    'DESCRIP' => 'detalle',
    'CODESTADO' => 'state',
    'OBSERV' => 'observation',
    'COSTO' => 'precio'
  }

  STATE = {
    'Bueno' => '1',
    'Regular' => '2',
    'Malo' => '3'
  }

  belongs_to :auxiliary
  belongs_to :user, counter_cache: true
  belongs_to :ingreso
  belongs_to :baja
  belongs_to :ubicacion

  has_many :asset_proceedings
  has_many :proceedings, through: :asset_proceedings
  has_many :cierre_gestiones
  has_many :gestiones, through: :cierre_gestiones
  has_and_belongs_to_many :seguros

  scope :assigned, -> { where.not(user_id: nil) }
  scope :unassigned, -> { where(user_id: nil) }
  scope :conbaja, -> { where.not(baja_id: nil) }
  scope :sinbaja, -> { where(baja_id: nil) }
  
  with_options if: :is_not_migrate? do |m|
    # m.validates :barcode, presence: true, uniqueness: true
    m.validates :code, presence: true, uniqueness: true
    m.validates :detalle, :auxiliary_id, :precio, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: true
    m.validates :description, presence: true
  end

  before_save :establecer_barcode
  before_validation :generar_descripcion

  has_paper_trail

  # Activos dados de baja
  def self.bajas
    joins(:baja)
  end

  def self.busqueda_basica(col, q, cuentas, desde, hasta)
    activos = self.select('assets.id as id, assets.code as codigo, assets.description as descripcion, assets.precio as precio, ingresos.factura_numero as factura, ingresos.factura_fecha as fecha_ingreso, accounts.name as cuenta, ubicaciones.abreviacion as lugar')
                  .joins('LEFT JOIN ingresos ON assets.ingreso_id = ingresos.id')
                  .joins('LEFT JOIN ubicaciones ON ubicaciones.id = assets.ubicacion_id')
                  .joins(auxiliary: [:account])
                  .where(baja_id: nil)
    if q.present? || cuentas.present? || (desde.present? && hasta.present?) || col.present?
      if q.present?
        if col == 'all'
          activos = activos.where('
                      ubicaciones.descripcion LIKE :de OR
                      ubicaciones.abreviacion LIKE :ab OR
                      assets.description LIKE :q OR
                      assets.code LIKE :code OR
                      ingresos.factura_numero LIKE :nf', de: "%#{q}%",
                                                         ab: "%#{q}%",
                                                         q: "%#{q}%",
                                                         code: "%#{q}%",
                                                         nf: "%#{q}%")
        else
          case col
          when 'code'
            activos = activos.where("assets.code LIKE :q", q: "%#{q}%")
          when 'description'
            activos = activos.where("assets.description LIKE :q", q: "%#{q}%")
          when 'invoice'
            activos = activos.where("ingresos.factura_numero = :q", q: q)
          end
        end
      end
      if cuentas.present?
        activos = activos.where("accounts.id = :c", c: cuentas)
      end
      if desde.present? && hasta.present?
        activos = activos.where("ingresos.factura_fecha" => desde..hasta)
      end
    end
    activos
  end

  def self.busqueda_avanzada(codigo, numero_factura, descripcion, cuenta, precio, desde, hasta, ubicacion)
    activos = self.select("assets.id as id, assets.code as codigo, assets.description as descripcion, assets.precio as precio, ingresos.factura_numero as factura, ingresos.factura_fecha as fecha_ingreso, accounts.name as cuenta, ubicaciones.abreviacion as lugar")
                  .joins("LEFT JOIN ingresos ON assets.ingreso_id = ingresos.id")
                  .joins("LEFT JOIN ubicaciones ON ubicaciones.id = assets.ubicacion_id")
                  .joins(auxiliary: [:account])
                  .where(baja_id: nil)
    if codigo.present?
      activos = activos.where("assets.code = :co", co: codigo)
    end
    if numero_factura.present?
      activos = activos.where("ingresos.factura_numero = :nf", nf: numero_factura)
    end
    if descripcion.present?
      activos = activos.where("assets.description LIKE :de", de: "%#{descripcion}%")
    end
    if precio.present?
      activos = activos.where("accounts.id = :pr", pr: precio)
    end
    if cuenta.present?
      activos = activos.where("accounts.id = :cu", cu: cuenta)
    end
    if desde.present? && hasta.present?
      activos = activos.where("ingresos.factura_fecha" => desde..hasta)
    end
    if ubicacion.present?
      activos = activos.where('ubicaciones.descripcion LIKE :de OR ubicaciones.abreviacion LIKE :ab', de: "%#{ubicacion}%", ab: "%#{ubicacion}%")
    end
    activos
  end

  def self.buscar_por_barcode(barcode)
    barcodes = barcode.split(',').map(&:strip)
    barcodes.map! do |rango|
      guiones = rango.split('-').map(&:strip)
      guiones.length > 1 ? Array(guiones[0].to_i..guiones[1].to_i).map(&:to_s) : guiones
    end
    self.todos.where(barcode: barcodes.flatten.uniq).order(:code)
  end

  #agregados
  def self.buscar_barcode_to_pdf(barcode, type, gestion)
    codes = []
    # separacion por , y ; (se obtiene el listado de codigos) 
    codes_aux = barcode.split(';').map { |c| c.split(',') }.flatten
    codes_aux = codes_aux.map(&:strip).select(&:present?)
    # procesamiento de - (rangos) 
    guiones_aux = codes_aux
    codes_aux = []
    guiones_aux.each do |code|
      if code.include?('-')
        rango = code.split('-').map(&:strip)
        codes_aux << Array(rango[0].to_i..rango[-1].to_i).map(&:to_s)
      else
        codes_aux << code
      end
    end
    codes_aux = codes_aux.flatten.select(&:present?)
    # procesamiento de x(nro de veces)
    codes_aux.each do |code|
      code.downcase!
      if type == 'ACT'
        if code.include?('x')
          mult = code.split('x').map(&:strip).select(&:present?)
          n_veces = mult[0].present? ? mult[0].to_i : 1
          new_code = (mult.size > 1 ? mult[-1] : nil)
          code_json = {barcode: nil , detalle: nil}
          if new_code.present?
            asset = Asset.where(barcode: new_code).first
            code_json = { barcode: asset.barcode , detalle: asset.detalle} if asset.present?
          end
          codes << [code_json]*n_veces
        else
          # caso codigo de activos  
          asset = Asset.where(barcode: code).first
          codes << { barcode: asset.barcode , detalle: asset.detalle} if asset.present?
        end
      else
        # caso numero de ingreso  
        if code.include?('x')
          mult = code.split('x').map(&:strip).select(&:present?)
          n_veces = mult[0].present? ? mult[0].to_i : 1
          code_json = {barcode: nil , detalle: nil}
          codes << [code_json]*n_veces
        else
          ingreso = Ingreso.where(numero: code).gestion(gestion).first
          if ingreso.present?
            ingreso.assets.each do |asset|
              codes << { barcode: asset.barcode , detalle: asset.detalle } if asset.present?
            end
          end
        end
      end
    end
    codes = codes.flatten
  end

  # Columnas para el DataTable
  def self.columnas
    # TODO se tiene que corregir el último campo assets.code para
    # ordenación de seguros
    %w[assets.code assets.code_old description ingresos.factura_fecha assets.precio suppliers.name accounts.name users.name ubicaciones.abreviacion assets.code]
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo
    Asset.all.empty? ? 1 : Asset.maximum(:code) + 1
  end

  def self.historical_assets(user)
    includes(:user).joins(:asset_proceedings).where(asset_proceedings: {proceeding_id: user.proceeding_ids})
  end

  # Metodo para ordenar por la fecha de ingreso de los activos.
  def self.ordenar_fecha_factura(activos)
    activos.sort { |a, b| [a['ANO'], a['MES'], a['DIA']] <=> [b['ANO'], b['MES'], b['DIA']] }
  end

  def auxiliary_code
    auxiliary.present? ? auxiliary.code : ''
  end

  def auxiliary_name
    auxiliary.present? ? auxiliary.name : ''
  end

  def account
    auxiliary.present? ? auxiliary.account : nil
  end

  def account_code
    auxiliary.present? ? auxiliary.account_code : ''
  end

  def account_name
    auxiliary.present? ? auxiliary.account_name : ''
  end

  # Verificar si un activo está de baja
  def baja?
    baja.present?
  end

  # Número de documento de respaldo
  def baja_documento
    baja.present? ? baja.documento : ''
  end

  # Fecha de emisión del documento de respaldo
  def baja_fecha_documento
    baja.present? ? baja.fecha_documento : nil
  end

  # Fecha de la baja
  def baja_fecha
    baja.present? ? baja.fecha : nil
  end

  def baja_motivo
    baja.present? ? baja.motivo : ''
  end

  def baja_observacion
    baja.present? ? baja.observacion : ''
  end

  def establecer_barcode
    self.barcode = self.code
  end

  # Fecha de ingreso del activo fijo
  def ingreso_fecha
    ingreso.present? ? ingreso.factura_fecha : nil
  end

  def ingreso_proveedor
    ingreso.present? ? ingreso.supplier : nil
  end

  # Fecha de ingreso del activo fijo
  def ingreso_proveedor_nombre
    ingreso.present? ? ingreso.supplier_name : nil
  end

  def nro_factura
    ingreso.present?  ? ingreso.factura_numero : nil
  end

  def name
    description
  end

  def user_code
    user.present? ? user.code : ''
  end

  def user_name
    user.present? ? user.name : ''
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'code_old'), h.get_column(self, 'description'), h.get_column(self, 'incorporacion'), h.get_column(self, 'supplier'), h.get_column(self, 'account'), h.get_column(self, 'user'), h.get_column(self, 'ubicacion')]
  end

  def self.without_barcode
    where("barcode IS NULL OR barcode = ''")
  end

  def self.without_user
    where(user_id: nil)
  end

  def verify_assignment
    false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, status)
    array = 
      if !status.present? || status == 'sin_bajas'
        sinbaja.includes(:ingreso, :user, :ubicacion, ingreso: :supplier, auxiliary: :account)
      elsif status == 'con_bajas'
        conbaja.includes(:ingreso, :user, :ubicacion, :baja, ingreso: :supplier, auxiliary: :account)
      else
        includes(:ingreso, :user, :ubicacion, :baja, ingreso: :supplier, auxiliary: :account)
      end
    array = array.order("#{sort_column} #{sort_direction}").references(auxiliary: :account)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        if search_column == 'account'
          array = array.where('accounts.name LIKE ? AND accounts = ?', "%#{sSearch}%", '1')
        elsif search_column == 'incorporacion' # modelo: Ingreso
          array = array.where('ingresos.factura_fecha LIKE ?', "%#{convertir_fecha(sSearch)}%")
        elsif search_column == 'supplier' # modelo: Supplier / Proveedor
          array = array.where('suppliers.name LIKE ?', "%#{sSearch}%")
        elsif search_column == 'ubicacion' # modelo: Ubicacion
          array = array.where('ubicaciones.abreviacion LIKE ?', "%#{sSearch}%")
        else
          type_search = search_column == 'user' ? 'users.name' : "assets.#{search_column}"
          array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
        end
      else
         array = array.where("assets.code LIKE ? OR assets.code_old LIKE ? OR assets.description LIKE ? OR users.name LIKE ? OR accounts.name LIKE ? OR suppliers.name LIKE ? OR ingresos.factura_fecha LIKE ? OR ubicaciones.abreviacion LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{convertir_fecha(sSearch)}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code description precio supplier incorporacion account user ubicacion fecha_baja)
    columns_title = columns
    CSV.generate do |csv|
      csv << columns_title.map { |c| self.human_attribute_name(c) }
      all.each do |asset|
        a = asset.attributes.values_at(*columns).compact
        a.push(asset.ingreso_proveedor_nombre)
        a.push(asset.ingreso_fecha)
        a.push(asset.account_name)
        a.push(asset.user_name)
        a.push(asset.ubicacion_detalle)
        a.push(asset.baja_fecha.present? ? I18n.l(asset.baja_fecha.to_date) : '')
        csv << a
      end
    end
  end

  def self.total_historico
    all.sum(:precio)
  end

  def get_state
    case state
    when 1 then 'Bueno'
    when 2 then 'Regular'
    when 3 then 'Malo'
    end
  end

  ##
  ## BEGIN Los campos de la tabla para el reporte de Depreciación de Activos Fijos

  def revaluo_inicial
    # TODO completar de acuerdo a lo requerido
    'N'
  end

  # UFV inicial en base a la fecha de compra o ingreso
  def indice_ufv
    ingreso_fecha.present? ? Ufv.indice(ingreso_fecha) : 0
  end

  # Costo histórico con el que se compró el activo fijo
  def costo_historico
    # TODO cuando hay revalúos hay cambio, actualmente no está considerado
    precio
  end

  # Costo actualizado inicial
  def costo_actualizado_inicial(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    ag = cierre_gestiones.where('fecha < ?', fecha).sum(:actualizacion_gestion)
    costo_historico + ag
  end

  def depreciacion_acumulada_inicial(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    cierre_gestiones.where('fecha < ?', fecha).sum(:depreciacion_gestion)
  end

  # Vida útil del activo fijo
  def vida_util_residual_nominal
    auxiliary.present? ? auxiliary.account_vida_util : 0
  end

  def factor_actualizacion(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    cg = cierre_gestiones.where('fecha < ?', fecha).order(:fecha).last
    ufv = cg.present? ? cg.indice_ufv : indice_ufv
    ufv != 0 ? (Ufv.indice(fecha) / ufv) : 0
  end

  def actualizacion_gestion(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    costo_actualizado(fecha) - costo_actualizado_inicial(fecha)
  end

  def costo_actualizado(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    _fecha = determinar_fecha_de_baja(fecha)
    costo_actualizado_inicial(_fecha) * factor_actualizacion(_fecha)
  end

  def porcentaje_depreciacion_anual
    100 / vida_util_residual_nominal.to_f
  end

  # Días desde la adquisición del activo fijo
  def dias_consumidos(fecha = Date.today)
    (fecha.to_date - ingreso_fecha.to_date).to_i + 1 rescue 0
  end

  # Días desde el último cierre de gestión
  def dias_consumidos_ultimo(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    cg = cierre_gestiones.where('fecha < ?', fecha).order(:fecha).last
    cg.present? ? (fecha.to_date - cg.fecha.to_date).to_i : dias_consumidos(fecha)
  end

  def depreciacion_gestion(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    _fecha = determinar_fecha_de_baja(fecha)
    costo_actualizado(_fecha) / 365.0 * dias_consumidos_ultimo(_fecha) * porcentaje_depreciacion_anual / 100.0
  end

  def fecha_fin_vida_util
    ingreso_fecha + account.vida_util.years - 1.day
  end

  def actualizacion_depreciacion_acumulada(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    depreciacion_acumulada_inicial(fecha) * (factor_actualizacion(fecha) - 1)
  end

  def depreciacion_acumulada_total(fecha = Date.today)
    fecha = fecha_fin_vida_util if fecha > fecha_fin_vida_util
    _fecha = determinar_fecha_de_baja(fecha)
    costo_actualizado(_fecha) / 365 * dias_consumidos(_fecha) * porcentaje_depreciacion_anual / 100
  end

  def valor_neto(fecha = Date.today)
    # El método redondear es un requisito para igualar a los resultados emitidos
    # por el sistema vSIAF del ministerio
    return 1 if (resultado = redondear(costo_actualizado(fecha)) - redondear(depreciacion_acumulada_total(fecha))) <= 0
    # resultado = redondear(costo_actualizado(fecha)) - redondear(depreciacion_acumulada_total(fecha))
    resultado
  end

  def valor_neto_inicial(fecha = Date.today)
    # El método redondear es un requisito para igualar a los resultados emitidos
    # por el sistema vSIAF del ministerio

    redondear(costo_actualizado_inicial(fecha)) - redondear(depreciacion_acumulada_inicial(fecha))
  end

  def dar_revaluo_o_baja
    # TODO cuando el activo está de baja o se haya revaluado
    'NO'
  end

  def self.costo_historico
    all.inject(0) { |s, a| redondear(a.costo_historico) + s }
  end

  def self.costo_actualizado_inicial(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.costo_actualizado_inicial(fecha)) + s }
  end

  def self.depreciacion_acumulada_inicial(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.depreciacion_acumulada_inicial(fecha)) + s }
  end

  def self.actualizacion_gestion(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.actualizacion_gestion(fecha)) + s }
  end

  def self.costo_actualizado(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.costo_actualizado(fecha)) + s }
  end

  def self.depreciacion_gestion(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.depreciacion_gestion(fecha)) + s }
  end

  def self.actualizacion_depreciacion_acumulada(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.actualizacion_depreciacion_acumulada(fecha)) + s }
  end

  def self.depreciacion_acumulada_total(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.depreciacion_acumulada_total(fecha)) + s }
  end

  def self.valor_neto(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.valor_neto(fecha)) + s }
  end

  def self.valor_neto_inicial(fecha = Date.today)
    all.inject(0) { |s, a| redondear(a.valor_neto_inicial(fecha)) + s }
  end

  ## END Los campos de la tabla para el reporte de Depreciación de Activos Fijos
  ##

  ##
  # Cerrar gestión actual de los subartículos
  def self.cerrar_gestion_actual(fecha = Date.today)
    activos = includes(:ingreso)
    activos = activos.where("ingresos.factura_fecha <= ?", fecha).references(:ingreso)
    self.transaction do
      activos.each do |activo|
        activo.cerrar_gestion_actual(fecha)
      end
    end
  end

  # Inserta un nuevo registro en la tabla cierre_gestiones
  def cerrar_gestion_actual(fecha = Date.today)
    gestion = Gestion.find_by(anio: fecha.year)
    activo = self
    cierre_gestion = CierreGestion.find_by(asset: activo, gestion: gestion)
    unless cierre_gestion.present?
      cierre_gestion = CierreGestion.new(asset: activo, gestion: gestion)
      cierre_gestion.actualizacion_gestion = activo.actualizacion_gestion(fecha)
      cierre_gestion.depreciacion_gestion = activo.depreciacion_gestion(fecha)
      cierre_gestion.indice_ufv = Ufv.indice(fecha)
      cierre_gestion.fecha = fecha
      cierre_gestion.save!
    end
  end

  def ubicacion_abreviacion
    ubicacion.present? ? ubicacion.abreviacion : ''
  end

  def ubicacion_descripcion
    ubicacion.present? ? ubicacion.descripcion : ''
  end

  def ubicacion_detalle
    ubicacion.present? ? ubicacion.detalle : ''
  end

  # Obtiene los activos sin seguro
  def self.sin_seguro_vigente
    seguros_vigentes_ids = Seguro.vigentes_incorporaciones.ids
    activos_ids = Asset.joins(:seguros)
                       .where(seguros: { id: seguros_vigentes_ids }).ids
    Asset.todos.where.not(id: activos_ids).order(:code)
  end

  # Obtiene la alerta para los activos sin seguro
  def self.alerta_sin_seguro_vigente
    sin_seguro_vigente.present?
  end

  def seguro_vigente?
    seguros_ids = Seguro.vigentes_incorporaciones.ids
    seguros.where(id: seguros_ids).present?
  end

  def self.todos
    self.select("assets.id, assets.code, assets.barcode, assets.description, assets.precio, ingresos.factura_numero, assets.detalle,  ingresos.factura_fecha, assets.observaciones, accounts.name as cuenta")
        .joins("LEFT JOIN ingresos ON assets.ingreso_id = ingresos.id")
        .joins(auxiliary: [:account])
        .sinbaja
  end

  # método que verifica si el activo tiene un código.
  def tiene_codigo?
    code.present?
  end

  # Método que genera un ingreso asociado a un activo para las migraciones.
  def generar_ingreso(anio, mes, dia)
    return unless anio.present? && mes.present? && dia.present?
    user = User.first
    supplier = Supplier.find_or_create_by(name: 'MIGRACION')
    ingreso = Ingreso.find_or_create_by(
      factura_fecha: Date.strptime("#{anio}-#{mes}-#{dia}", '%Y-%m-%d'),
      supplier_id: supplier.id,
      user_id: user.id
    )
    update_attributes!(ingreso_id: ingreso.id)
  end

  private

  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    asset = { is_migrate: true }
    CORRELATIONS.each do |origin, destination|
      asset.merge!(destination => record[origin])
    end
    ac = Account.find_by_code(record['CODCONT'])
    ax = Auxiliary.joins(:account).where(code: record['CODAUX'], accounts: { code: record['CODCONT'] }).take
    u = User.joins(:department).where(code: record['CODRESP'], departments: { code: record['CODOFIC'] }).take
    if asset.present? && (activo = new(asset.merge!(account_id: ac.id, auxiliary: ax, user: u ))).save
      if record['ANO'].present? && record['MES'].present? && record['DIA'].present?
        activo.generar_ingreso(record['ANO'], record['MES'], record['DIA'])
      end
    end
  end

  # Importa los datos de las UFVs y crea las gestiones correspondientes.
  def self.completa_migracion
    Ufv.descargar_e_importar_activos
    Gestion.generar_gestiones_migracion
  end

  ##
  # Permite convertir una fecha en string a un formato para búsqueda en base de datos
  # p.e. 30-03-2016 => 2016-03-30, 30-03 => 03-30, 30/03/2016 => 2016-03-30, 30/03 => 03-30
  def self.convertir_fecha(fecha)
    unless fecha =~ /[^0-9|\/|-]/
      return fecha.split('/').reverse.join('-') if fecha =~ /\//
      return fecha.split('-').reverse.join('-') if fecha =~ /-/
      return fecha.strip unless fecha =~ /[^0-9]/
    end
    return fecha
  end

  def generar_descripcion
    descripcion = []
    descripcion << detalle if detalle.present? && detalle.strip.present?
    descripcion << "MEDIDAS #{medidas}" if medidas.present? && medidas.strip.present?
    descripcion << "MATERIAL #{material}" if material.present? && material.strip.present?
    descripcion << "COLOR #{color}" if color.present? && color.strip.present?
    descripcion << "MARCA #{marca}" if marca.present? && marca.strip.present?
    descripcion << "MODELO #{modelo}" if modelo.present? && modelo.strip.present?
    descripcion << "SERIE #{serie}" if serie.present? && serie.strip.present?
    self.description = descripcion.join(' ').squish
  end

  private

    # Determinar si el activo fue dado de baja y tomar su fecha de baja
    def determinar_fecha_de_baja(fecha)
      _fecha = fecha
      if self.baja? && self.baja_fecha.present? && self.baja_fecha.to_date <= fecha.to_date
        _fecha = self.baja_fecha.to_date
      end
      _fecha
    end
end
