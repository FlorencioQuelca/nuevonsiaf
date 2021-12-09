class Proceeding < ActiveRecord::Base
  include VersionLog

  default_scope -> { where(baja_logica: false) }

  PROCEEDING_TYPE = {
    'E' => 'assignation',
    'D' => 'devolution'
  }

  belongs_to :user
  belongs_to :admin, class_name: 'User'

  has_many :asset_proceedings
  has_many :assets, through: :asset_proceedings

  before_create :actualizar_fecha
  after_create :update_assignations

  has_paper_trail on: [:destroy]

  def self.assignation
    where(proceeding_type: 'E')
  end

  def self.devolution
    where(proceeding_type: 'D')
  end

  def self.set_columns
   h = ApplicationController.helpers
   c_names = column_names - %w(id created_at updated_at proceeding_type)
   c_names.map{ |c| h.get_column(self, c) unless c == 'object' }.compact
  end

  def admin_name
    admin ? admin.name : ''
  end

  def code
    user ? user.depto_code : ''
  end

  def name
    user ? user.depto_name : ''
  end

  def get_type
    PROCEEDING_TYPE[proceeding_type]
  end

  def cite_plantillas
    if (datos = plantillas_info).present?
      datos = (JSON.parse(datos) rescue {})
      datos["cite"].present? ? datos["cite"] : ''
    else
      ''
    end
  end

  ##
  # Tipo de Acta:
  #   E: Asignación, Entrega de Activos
  #   D: Devolución de Activos
  def is_assignation?
    proceeding_type == 'E'
  end

  def is_devolution?
    proceeding_type == 'D'
  end

  def user_name
    user ? user.name : ''
  end

  def user_ci
    user ? user.ci : ''
  end

  def user_title
    usuarios = JSON.parse(usuario_info || {}.to_json)
    (usuarios.present? && usuarios['solicitado_por'].present? && usuarios['solicitado_por']['cargo'].present? ) ? usuarios['solicitado_por']['cargo'] : ''
    # user ? user.title : ''
  end

  def user_department
    usuarios = JSON.parse(usuario_info || {}.to_json)
    (usuarios.present? && usuarios['solicitado_por'].present? && usuarios['solicitado_por']['unidad'].present? ) ? usuarios['solicitado_por']['unidad'] : ''
    # user ? user.department_name : ''
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:user, :admin).order("#{sort_column} #{sort_direction}").references(:user, :admin)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = "proceedings.#{search_column}"
        case search_column
        when 'user_id' then type_search = 'users.name'
        when 'admin_id' then type_search = 'admins_proceedings.name'
        end
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")#.references(:user, :admin)
      else
        array = array.where("users.name LIKE ? OR admins_proceedings.name LIKE ? OR proceedings.plantillas_info LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  private

  def actualizar_fecha
    self.fecha ||= self.created_at
  end

  def update_assignations
    user_id = nil # self.admin_id
    event = 'devolution'
    if is_assignation?
      user_id = self.user_id
      event = 'assignation'
    end
    Asset.paper_trail.disable
    assets.map { |a| a.update_attributes(user_id: user_id) }
    Asset.paper_trail.enable
    register_log(event)
  end

  def self.to_csv
    columns = %w(cite_plantillas user_id admin_id proceeding_type created_at)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |proceeding|
        a = Array.new
        (a << proceeding.cite_plantillas)if Rails.application.secrets.interoperabilidad_plantillas.present?
        a << proceeding.user_name
        a << proceeding.admin_name
        a << I18n.t(proceeding.get_type, scope: 'proceedings.type')
        a << I18n.l(proceeding.created_at, format: :version)
        csv << a
      end
    end
  end
end
