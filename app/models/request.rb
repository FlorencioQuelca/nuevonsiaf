class Request < ActiveRecord::Base
  include Autoincremento
  default_scope {where(invalidate: false)}

  scope :del_anio_por_fecha_creacion, -> (fecha) { where(created_at: fecha.beginning_of_year..fecha.end_of_year) }
  scope :mayor_a_fecha_creacion, -> (fecha) { where('DATE(created_at) > ?', fecha) }
  scope :menor_igual_a_fecha_creacion, -> (fecha) { where('DATE(created_at) <= ?', fecha) }
  scope :con_fecha_creacion, -> { where.not(created_at: nil) }
  scope :con_nro_solicitud, -> { where.not(nro_solicitud: nil).where.not(nro_solicitud: 0)}

  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :subarticle_requests
  has_many :subarticles, through: :subarticle_requests
  accepts_nested_attributes_for :subarticle_requests

  validates :documento_id, uniqueness: true, if: 'documento_id.present?'

  def user_name
    user.present? ? user.name : ''
  end

  def user_title
    usuarios = JSON.parse(json_usuarios || {}.to_json)
    (usuarios.present? && usuarios['solicitado_por'].present? && usuarios['solicitado_por']['cargo'].present? ) ? usuarios['solicitado_por']['cargo'] : ''
    # user.present? ? user.title : ''
  end

  def user_name_title
    "#{user_name}-#{user_title}".strip
  end

  def admin_name
    admin.present? ? admin.name : ''
  end

  def self.set_columns(mostrar_filtro_cite = false)
    h = ApplicationController.helpers
    columnas = [h.get_column(self, 'created_at'), h.get_column(self, 'nro_solicitud'), h.get_column(self, 'name'), h.get_column(self, 'title')]
    if mostrar_filtro_cite
      columnas << h.get_column(self, 'cite_ems')
    end
    columnas
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, status)
    orden = "#{sort_column} #{sort_direction}"
    case sort_column
    when "requests.created_at"
      orden += ", requests.nro_solicitud #{sort_direction}, requests.incremento_alfabetico #{sort_direction}"
    when "requests.nro_solicitud"
      orden += ", requests.incremento_alfabetico #{sort_direction}"
    end
    status = status == '' || status == nil ? 'all' : status
    array = joins(:user).order(orden)
    array = array.where(status: status) unless status == 'all'
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(name title).include?(search_column) ? "users.#{search_column}" : "requests.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        if status != 'initiation'
          array = array.where("requests.nro_solicitud LIKE ? OR  requests.created_at LIKE ? OR users.name LIKE ? OR users.title LIKE ? OR requests.cite_ems LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
        else
          array = array.where("requests.nro_solicitud LIKE ? OR  requests.created_at LIKE ? OR users.name LIKE ? OR users.title LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
        end
      end
    end
    array
  end

  def self.to_csv
    columns = %w(nro_solicitud created_at name title status)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |request|
        a = []
        a.push(request.obtiene_numero_solicitud)
        a.push(I18n.l(request.created_at, format: :version))
        a.push(request.user_name)
        a.push(request.user_title)
        a.push(I18n.t("requests.title.status.#{request.status}"))
        csv << a
      end
    end
  end

  def self.numero_solicitud_anterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_creacion(fecha).menor_igual_a_fecha_creacion(fecha).con_nro_solicitud.maximum(:nro_solicitud)
  end

  def self.numero_solicitud_posterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_creacion(fecha).mayor_a_fecha_creacion(fecha).con_nro_solicitud.minimum(:nro_solicitud)
  end

  def tiene_numero?
    nro_solicitud.present? && nro_solicitud != 0
  end

  def self.numero_solicitud_posterior_regularizado(fecha)
    fecha = fecha.to_date
    numero = self.numero_solicitud_anterior(fecha)
    self.del_anio_por_fecha_creacion(fecha).mayor_a_fecha_creacion(fecha).where(nro_solicitud: numero).first.try(:incremento_alfabetico)
  end

  def self.obtiene_siguiente_numero_solicitud(fecha)
    codigo_numerico = nil
    codigo_alfabetico = nil
    respuesta_hash = {}
    if fecha.present?
      fecha = fecha.to_date
      numero_solicitud_anterior = self.numero_solicitud_anterior(fecha)
      numero_solicitud_posterior = self.numero_solicitud_posterior(fecha)
      if numero_solicitud_anterior.present? && !numero_solicitud_posterior.present?
        respuesta_hash[:codigo_numerico] = numero_solicitud_anterior.to_i + 1
      elsif !numero_solicitud_anterior.present? && !numero_solicitud_posterior.present?
        respuesta_hash[:codigo_numerico] = 1
      elsif numero_solicitud_anterior.present? && numero_solicitud_posterior.present?
        diferencia = numero_solicitud_posterior - numero_solicitud_anterior
        if diferencia > 1
          respuesta_hash[:codigo_numerico] = numero_solicitud_anterior.to_i + 1
          respuesta_hash[:tipo_respuesta] = 'confirmacion'
          respuesta_hash[:numero] = numero_solicitud_anterior.to_i + 1
          ultima_fecha = del_anio_por_fecha_creacion(fecha).order(created_at: :desc).first.try(:created_at)
          ultima_fecha = ultima_fecha.strftime('%d/%m/%Y') if ultima_fecha.present?
          respuesta_hash[:ultima_fecha] = ultima_fecha
        else
          inc_alfabetico = numero_solicitud_posterior_regularizado(fecha)
          if inc_alfabetico.present?
            solicitud_anterior = del_anio_por_fecha_creacion(fecha).con_nro_solicitud.menor_igual_a_fecha_creacion(fecha).order(created_at: :desc, nro_solicitud: :desc, incremento_alfabetico: :desc).first
            solicitud_posterior = del_anio_por_fecha_creacion(fecha).con_nro_solicitud.mayor_a_fecha_creacion(fecha).order(created_at: :asc, nro_solicitud: :asc, incremento_alfabetico: :asc).first
            respuesta_hash[:tipo_respuesta] = 'alerta'
            respuesta_hash[:fecha] = fecha.strftime('%d/%m/%Y')
            respuesta_hash[:numero_solicitud_anterior] = solicitud_anterior.obtiene_numero_solicitud
            respuesta_hash[:fecha_solicitud_anterior] = solicitud_anterior.created_at.strftime('%d/%m/%Y') if solicitud_anterior.created_at.present?
            respuesta_hash[:numero_solicitud_posterior] =  solicitud_posterior.obtiene_numero_solicitud
            respuesta_hash[:fecha_solicitud_posterior] = solicitud_posterior.created_at.strftime('%d/%m/%Y') if solicitud_posterior.created_at.present?
          else
            max_incremento_alfabetico = where(nro_solicitud: numero_solicitud_anterior).order(incremento_alfabetico: :desc).first.incremento_alfabetico
            codigo_numerico = numero_solicitud_anterior.to_i
            codigo_alfabetico = max_incremento_alfabetico.present? ? max_incremento_alfabetico.next : "A"
            ultima_fecha = del_anio_por_fecha_creacion(fecha).order(created_at: :desc).first.try(:created_at)
            ultima_fecha = ultima_fecha.strftime('%d/%m/%Y') if ultima_fecha.present?
            respuesta_hash[:tipo_respuesta] = 'confirmacion'
            respuesta_hash[:numero] = codigo_alfabetico.present? ? "#{codigo_numerico}-#{codigo_alfabetico}" : "#{codigo_numerico}"
            respuesta_hash[:codigo_numerico] = codigo_numerico
            respuesta_hash[:codigo_alfabetico] = codigo_alfabetico
            respuesta_hash[:ultima_fecha] = ultima_fecha
          end
        end
      else
        if numero_solicitud_posterior > 1
          respuesta_hash[:codigo_numerico] = numero_solicitud_posterior.to_i - 1
        else
          respuesta_hash[:tipo_respuesta] = 'alerta'
          respuesta_hash[:fecha] = fecha.strftime('%d/%m/%Y')
          solicitud_posterior = del_anio_por_fecha_creacion(fecha).con_nro_solicitud.mayor_a_fecha_creacion(fecha).order(created_at: :asc, nro_solicitud: :asc, incremento_alfabetico: :asc).first
          respuesta_hash[:numero_solicitud_posterior] =  solicitud_posterior.obtiene_numero_solicitud
          respuesta_hash[:fecha_solicitud_posterior] = solicitud_posterior.created_at.strftime('%d/%m/%Y') if solicitud_posterior.created_at.present?
        end
      end
    end
    respuesta_hash
  end

  def request_deliver
    anulado = true
    subarticle_requests.each do |subarticle_request|
      if subarticle_request.amount_delivered > 0
        anulado = false
        break
      end
    end
    estado = anulado ? 'canceled' : 'delivered'
    update_attributes(status: estado, delivery_date: created_at)
  end

  # Entrega los productos solicitados
  def entregar_subarticulos(request_params)
    ActiveRecord::Base.transaction do
      update(request_params)
      subarticle_requests.entregar_subarticulos
      request_deliver
    end
    true
  rescue
    false
  end

  # Anula una Solicitud de Material, y también de los subartículos seleccionados
  # y es necesario especificar el motivo de la anulación.
  def invalidate_request(message="")
    transaction do
      update(invalidate: true, message: message)
      subarticle_requests.invalidate_subarticles
    end
  end

  def obtiene_numero_solicitud
    if !incremento_alfabetico.present?
      nro_solicitud.to_s
    else
      "#{nro_solicitud}-#{incremento_alfabetico}"
    end
  end

  def validar_cantidades(cantidades_subarticulo)
    subarticle_requests.validar_cantidades(cantidades_subarticulo)
  end

  def tipo_estado
    case status
    when 'initiation'
      'warning'
    when 'delivered'
      'success'
    when 'canceled'
      'default'
    end
  end
end
