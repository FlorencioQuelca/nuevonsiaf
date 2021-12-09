
class Ingreso < ActiveRecord::Base
  include Autoincremento

  default_scope -> { where(baja_logica: false) }

  scope :del_anio_por_fecha_factura, -> (fecha) { where(factura_fecha: fecha.beginning_of_year..fecha.end_of_year) }
  scope :mayor_a_fecha_factura, -> (fecha) { where('factura_fecha > ?', fecha) }
  scope :menor_igual_a_fecha_factura, -> (fecha) { where('factura_fecha <= ?', fecha) }
  scope :con_fecha_factura, -> { where.not('factura_fecha is null') }
  scope :con_numero, -> { where('numero is not null')}
  scope :gestion, ->(gestion) { where('EXTRACT(YEAR FROM COALESCE(factura_fecha, nota_entrega_fecha)) = ?', gestion) }

  belongs_to :supplier
  has_many :assets
  belongs_to :user

  validates :documento_id, uniqueness: true, if: 'documento_id.present?'

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    orden = "#{sort_column} #{sort_direction}"
    case sort_column
    when "ingresos.factura_fecha"
      orden += ", ingresos.numero #{sort_direction}, ingresos.incremento_alfabetico #{sort_direction}"
    when "ingresos.numero"
      orden += ", ingresos.incremento_alfabetico #{sort_direction}"
    end
    array = joins(:user, :supplier).order(orden)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(users suppliers).include?(search_column) ? "#{search_column}.name" : "ingresos.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("ingresos.factura_fecha LIKE ? OR ingresos.numero LIKE ? OR ingresos.factura_numero LIKE ? OR suppliers.name LIKE ? OR users.name LIKE ? OR ingresos.total LIKE ? OR ingresos.documento_cite LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    columnas = [h.get_column(self, 'numero'), h.get_column(self, 'factura_fecha'), h.get_column(self, 'factura_numero'), h.get_column(self, 'supplier'), h.get_column(self, 'users'), h.get_column(self, 'total'), h.get_column(self, 'nota_entrega_fecha')]

    if Rails.application.secrets.interoperabilidad_plantillas.present?
      columnas << h.get_column(self, 'documento_cite')
    end
    columnas
  end

  def self.to_csv
    columns = %w(numero factura_fecha factura_numero supplier telefono users total nota_entrega_fecha)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Ingreso.human_attribute_name(c) }
      all.each do |ingreso|
        a = Array.new
        a << ingreso.numero
        a << ingreso.factura_fecha
        a << ingreso.factura_numero
        a << ingreso.supplier_name
        a << ingreso.telefono_proveedor
        a << ingreso.user_name
        a << ingreso.total
        a << ingreso.nota_entrega_fecha
        csv << a
      end
    end
  end

  # Método para obtener las gestiones involucradas de los ingresos generados.
  def self.obtiene_gestiones
    Ingreso.select('extract(year from factura_fecha) as gestion')
           .group('extract(year from factura_fecha)')
           .order('extract(year from factura_fecha) asc')
  end

  def self.obtiene_gestiones_desc
    self.obtiene_gestiones
        .map { |i| i.gestion }
        .select { |g| g.present? }.sort.reverse!
  end

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def supplier_nit
    supplier.present? ? supplier.nit : ''
  end

  def supplier_telefono
    supplier.present? ? supplier.telefono : ''
  end

  def user_name
    user.present? ? user.name : ''
  end

  def telefono_proveedor
    supplier.telefono
  end

  def obtiene_numero
    if !incremento_alfabetico.present?
      "#{numero}"
    else
      "#{numero}-#{incremento_alfabetico}"
    end
  end

  def self.numero_ingreso_anterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_factura(fecha).menor_igual_a_fecha_factura(fecha).con_numero.maximum(:numero)
  end

  def self.numero_ingreso_posterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_factura(fecha).mayor_a_fecha_factura(fecha).con_numero.minimum(:numero)
  end

  def tiene_numero?
    numero.present? && factura_numero.present?
  end

  def self.numero_ingreso_posterior_regularizado(fecha)
    fecha = fecha.to_date
    numero = self.numero_ingreso_anterior(fecha)
    self.del_anio_por_fecha_factura(fecha).mayor_a_fecha_factura(fecha).where(numero: numero).first.try(:incremento_alfabetico)
  end

  def self.obtiene_siguiente_numero_ingreso(fecha)
    codigo_numerico = nil
    codigo_alfabetico = nil
    respuesta_hash = Hash.new
    if fecha.present?
      fecha = fecha.to_date
      numero_ingreso_anterior = Ingreso.numero_ingreso_anterior(fecha)
      numero_ingreso_posterior = Ingreso.numero_ingreso_posterior(fecha)
      if numero_ingreso_anterior.present? && !numero_ingreso_posterior.present?
        respuesta_hash[:codigo_numerico] = numero_ingreso_anterior.to_i + 1
      elsif !numero_ingreso_anterior.present? && !numero_ingreso_posterior.present?
        respuesta_hash[:codigo_numerico] = 1
      elsif numero_ingreso_anterior.present? && numero_ingreso_posterior.present?
        diferencia = numero_ingreso_posterior - numero_ingreso_anterior
        if diferencia > 1
          respuesta_hash[:codigo_numerico] = numero_ingreso_anterior.to_i + 1
        else
          inc_alfabetico = Ingreso.numero_ingreso_posterior_regularizado(fecha)
          if inc_alfabetico.present?
            ingreso_anterior = Ingreso.del_anio_por_fecha_factura(fecha).con_numero.menor_igual_a_fecha_factura(fecha).order(factura_fecha: :desc, numero: :desc, incremento_alfabetico: :desc).first
            ingreso_posterior = Ingreso.del_anio_por_fecha_factura(fecha).con_numero.mayor_a_fecha_factura(fecha).order(factura_fecha: :asc, numero: :asc, incremento_alfabetico: :asc).first
            respuesta_hash[:tipo_respuesta] = "alerta"
            respuesta_hash[:fecha] = fecha.strftime("%d/%m/%Y")
            respuesta_hash[:numero_ingreso_anterior] = ingreso_anterior.obtiene_numero
            respuesta_hash[:fecha_ingreso_anterior] = ingreso_anterior.factura_fecha.strftime("%d/%m/%Y") if ingreso_anterior.factura_fecha.present?
            respuesta_hash[:numero_ingreso_posterior] =  ingreso_posterior.obtiene_numero
            respuesta_hash[:fecha_ingreso_posterior] = ingreso_posterior.factura_fecha.strftime("%d/%m/%Y") if ingreso_posterior.factura_fecha.present?
          else
            max_incremento_alfabetico = Ingreso.where(numero: numero_ingreso_anterior).order(incremento_alfabetico: :desc).first.incremento_alfabetico
            codigo_numerico = numero_ingreso_anterior.to_i
            codigo_alfabetico = max_incremento_alfabetico.present? ? max_incremento_alfabetico.next : "A"
            ultima_fecha = Ingreso.del_anio_por_fecha_factura(fecha).order(factura_fecha: :desc).first.try(:factura_fecha)
            ultima_fecha = ultima_fecha.strftime("%d/%m/%Y") if ultima_fecha.present?
            respuesta_hash[:tipo_respuesta] = "confirmacion"
            respuesta_hash[:numero] = codigo_alfabetico.present? ? "#{codigo_numerico}-#{codigo_alfabetico}" : "#{codigo_numerico}"
            respuesta_hash[:codigo_numerico] = codigo_numerico
            respuesta_hash[:codigo_alfabetico] = codigo_alfabetico
            respuesta_hash[:ultima_fecha] = ultima_fecha
          end
        end
      else
        if numero_ingreso_posterior > 1
          respuesta_hash[:codigo_numerico] = numero_ingreso_posterior.to_i - 1
        else
          respuesta_hash[:tipo_respuesta] = "alerta"
          respuesta_hash[:mensaje] = "No se puede introducir un ingreso para la fecha, por favor contactese con el administrador del sistema."
        end
      end
    end
    respuesta_hash
  end

end
