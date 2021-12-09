class User < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog, ManageStatus, EjecutarSQL

  CORRELATIONS = {
    'CODRESP' => 'code',
    'NOMRESP' => 'name',
    'CARGO' => 'title',
    'API_ESTADO' => 'status'
  }

  ROLES = %w[admin admin_store observador_almacen]

  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  CI_FORMAT = /\A([1-9]{1}[0-9]{4,15}(-[a-zA-Z0-9]{2})?)\z/i

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :department
  has_many :assets
  has_many :bajas
  has_many :proceedings, foreign_key: :user_id
  has_many :ingresos

  scope :actives, -> { where(status: '1') }

  with_options unless: :is_super_admin? do |m|
    m.validates :ci, presence: true, length: {minimum: 5, maximum: 20}, format: { with: CI_FORMAT }
    m.validates :name, :title, presence: true
    m.validates :department_id, presence: true
    m.validates :email, presence: true, format: { with: EMAIL_FORMAT }
    # m.validates :username, presence: true, length: {minimum: 4, maximum: 128}, uniqueness: true
    m.validates :phone, :mobile, numericality: { only_integer: true }, allow_blank: true
    # m.validates :code, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end

  validates :role, presence: true, format: { with: /#{ROLES.join('|')}/ },  if: :verify_is_admin?
  validates :password, presence: true, length: {minimum: 7},  if: :verify_is_admin?

  with_options if: :verify_is_not_group? do |m|
    m.validates :ci, uniqueness: true
    m.validates :email, uniqueness: true
  end

  before_save :dar_formato_datos

  before_validation :set_defaults

  has_paper_trail ignore: [:last_sign_in_at, :current_sign_in_at, :last_sign_in_ip, :current_sign_in_ip, :sign_in_count, :updated_at, :status, :password_change, :encrypted_password]

  def verify_is_admin?
    begin 
      Thread.current[:current_user].is_super_admin?
    rescue StandardError => e
      false
    end
  end

  def verify_is_not_group?
    begin 
      Thread.current[:fuente_actualizacion] != 'agrupacion'
    rescue StandardError => e
      false
    end
  end
  
  def active_for_authentication?
    super && self.status == '1'
  end

  def change_password(user_params)
    transaction do
      update_with_password(user_params) &&
        hide_announcement &&
        register_log(:password_changed)
    end
  end

  def inactive_message
    I18n.t('unauthorized.manage.user_inactive')
  end

  def department_entity_acronym
    department.present? ? department.entity_acronym : ''
  end

  def department_code
    department.present? ? department.code : ''
  end

  def department_name
    department.present? ? department.name : ''
  end

  def depto_code
    "#{department_code}#{code}"
  end

  def depto_name
    "#{department_name} - #{name}"
  end

  def email_required?
    false
  end

  def entity_name
    department.present? ? department.entity_name : ''
  end

  # Obtiene la imagen para los encabezados y pie para un documento
  def get_image(tipo)
    tipo == 'header' ? get_image_header : get_image_footer
  end

  # Obtiene la imagen para el pie de página de los documentos
  def get_image_footer
    department.present? ? department.get_image_footer : ''
  end

  # Obtiene la imagen para el encabezado de los documentos
  def get_image_header
    department.present? ? department.get_image_header : ''
  end

  def has_roles?
    self.role.present?
  end

  def hide_announcement
    update_column(:password_change, true)
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_admin_store?
    self.role == 'admin_store'
  end

  def is_admin_or_super?
    is_super_admin? || is_admin?
  end

  def is_super_admin?
    self.role == 'super_admin'
  end

  def is_observador_almacen?
    self.role == 'observador_almacen'
  end

  def not_assigned_assets
    # TODO Tiene que definirse que activos no están asignados,
    # tambien se debe tomar en cuenta las auto-asignaciones del admin
    assets
  end

  def obtiene_historico_almacenes(q)
    respuesta = Subarticle.joins(subarticle_requests: { request: :user })
                          .where('requests.status = ?', 'delivered')
                          .where('requests.user_id = ?', id)
                          .where('subarticle_requests.total_delivered > 0')
                          .select('requests.delivery_date as fecha_entrega, requests.id as request_id, subarticles.id as subarticulo_id, subarticles.code as subarticulo_codigo, subarticles.description as descripcion, requests.nro_solicitud as numero_solicitud, subarticle_requests.total_delivered as cantidad_entregado')
    respuesta = respuesta.where('subarticles.code like ? or subarticles.description like ? or requests.nro_solicitud like ?', "%#{q}%", "%#{q}%", "%#{q}%") if q.present?
    respuesta
  end

  def self.obtiene_csv_historial(datos)
    attributes = %w{solicitud fecha_entrega codigo descripcion cantidad}
    CSV.generate(headers: true) do |csv|
      csv << attributes
      datos.each do |fila|
        csv << [fila.numero_solicitud, fila.fecha_entrega, fila.subarticulo_codigo, fila.descripcion, fila.cantidad_entregado]
      end
    end
  end

  def password_changed?
    password_change == true
  end

  def users
    User.where('role IS NULL OR role != ?', 'super_admin')
  end

  def self.search_by(department_id)
    users = []
    users = where(department_id: department_id) if department_id.present?
    [['', '--']] + users.map { |u| [u.id, u.name] }
  end

  def self.set_columns(cu = nil)
    h = ApplicationController.helpers
    if cu
      [h.get_column(self, 'ci'), h.get_column(self, 'name'), h.get_column(self, 'role')]
    else
      [h.get_column(self, 'ci'), h.get_column(self, 'name'), h.get_column(self, 'title'), h.get_column(self, 'department')]
    end
  end

  def verify_assignment
    assets.present?
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user)
    array = current_user.users.includes(:department).order("#{sort_column} #{sort_direction}").references(:department)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == 'department' ? 'departments.name' : "users.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        if current_user.is_super_admin?
          array = array.where("users.name LIKE ? OR users.role LIKE ?", "%#{sSearch}%", "%#{sSearch}%")
        else
          array = array.where("users.code LIKE ? OR users.ci LIKE ? OR users.name LIKE ? OR users.title LIKE ? OR departments.name LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
        end
      end
    end
    array
  end

  def self.to_csv
    columns = %w(ci name title department status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |user|
        a = user.attributes.values_at(*columns)
        a.pop(2)
        a.push(user.department_name, h.type_status(user.status))
        csv << a
      end
    end
  end

  def self.search_user(q)
    h = ApplicationController.helpers
    h.status_active(self).where("name LIKE ? AND username != ?", "%#{q}%", 'admin').map{ |s| { id: s.id, name: s.name, title: s.title } }
  end

  def self.emparejar_usuario(usuario)
    nombre_persona_plantillas = "#{usuario[:nombres].strip} #{usuario[:apellidos].strip}"
    persona_bd = User.find_by(ci: usuario[:numero_documento].strip)
    persona_bd_id = nil
    mensaje = ''
    if persona_bd.present?
      persona_bd_id = persona_bd.id
      # Actualizar la unidad y cargo del solicitante
      unidad_id = obtener_unidad(usuario[:unidad])
      persona_bd.update(department_id: unidad_id, title: usuario[:cargo])
    else
      persona_bd = User.where('email = ? or name = ?', usuario[:email], nombre_persona_plantillas).first
      if !persona_bd.present?
        coincidencias = ejecutar_sql(
          sanitize_sql(["SELECT id, levenshtein(:name_input, name) as distance FROM users WHERE levenshtein(:name_input, name) BETWEEN 0 AND 3", name_input: nombre_persona_plantillas])
        )
        if coincidencias.count == 0
          # crear nuevo usuario
          unidad_id = obtener_unidad(usuario[:unidad])
          if unidad_id.present?
            codigo = User.maximum('code').to_i + 1
            user = User.new(email: usuario[:email], username: usuario[:numero_documento], name: nombre_persona_plantillas, title: usuario[:cargo], ci: usuario[:numero_documento].strip, department_id: unidad_id, code: codigo)
            if user.save
              persona_bd_id = user.id
              mensaje = 'Usuario creado'
            else
              mensaje = 'Error al crear el funcionario en Almacenes'
            end
          else
            mensaje = "La unidad #{usuario[:unidad]} no pudo ser creada en almacenes/activos. Verifique si existe esa unidad en el sistema de almacenes."
          end
        else
          mensaje = "Existe un registro coincidente con #{nombre_persona_plantillas} en el sistema de almacenes y/o activos. Ingrese a dicho sistema y verifique los datos del funcionario."
        end
  
      else
        # De almacenes debe limpiar y regularizar al usuario
        mensaje = "En el sistema de almacenes/activos ya existe una persona con el nombre #{nombre_persona_plantillas} y/o email #{usuario[:email]}. Ingrese a sistema de almacenes/activos y verifique los datos del funcionario."
      end
    end
    [persona_bd_id, mensaje]
  end

  def self.obtener_datos(usuario_id)
    respuesta = {}
    usuario = User.find(usuario_id)
    if usuario.present?
      respuesta = {id: usuario.id, nombre: ApplicationController.helpers.validar_valor(usuario.name), numero_documento: ApplicationController.helpers.validar_valor(usuario.ci), cargo: ApplicationController.helpers.validar_valor(usuario.title), unidad: ApplicationController.helpers.validar_valor(usuario.department_name), email: ApplicationController.helpers.validar_valor(usuario.email)}
    end
    respuesta
  end

  private

  def dar_formato_datos
    unless is_super_admin?
      self.name = self.name.upcase if self.name.present?
      self.title = self.title.upcase if self.title.present?
    end
  end

  # Obtiene la unidad
  def self.obtener_unidad(unidad_plantillas)
    depto = Department.find_by(name: unidad_plantillas)
    depto_id = nil
    if depto.present?
      depto_id = depto.id
    else
      codigo = Department.maximum('code').to_i + 1
      depto = Department.new(code: codigo, name: unidad_plantillas, building_id: 1)
      if depto.save
        depto_id = depto.id
      end
    end
    depto_id
  end

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    user = { is_migrate: true, password: 'Demo1234' }
    CORRELATIONS.each do |origin, destination|
      user.merge!({ destination => record[origin] })
    end
    d = Department.find_by_code(record['CODOFIC'])
    d.present? && user.present? && new(user.merge!({ department: d })).save
  end

  def set_defaults
    unless is_super_admin?
      self.username = self.ci
      if username_was.blank? && password.nil? && !username.nil?
        self.password ||= self.username
      end
    end
  end
end
