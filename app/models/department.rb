class Department < ActiveRecord::Base
  include ImportDbf, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODOFIC' => 'code',
    'NOMOFIC' => 'name',
    'API_ESTADO' => 'status'
  }

  belongs_to :building
  has_many :users

  scope :actives, -> { where(status: '1') }

  validates :code, presence: true, uniqueness: { scope: :building_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :name, presence: true, allow_blank: true
  validates :building_id, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def building_code
    building.present? ? building.code : ''
  end

  def building_name
    building.present? ? building.name : ''
  end

  def entity_acronym
    building.present? ? building.entity_acronym : ''
  end

  def entity_name
    building.present? ? building.entity_name : ''
  end

  # Obtiene la imagen para el pie de página de los documentos
  def get_image_footer
    building.present? ? building.get_image_footer : ''
  end

  # Obtiene la imagen para el encabezado de los documentos
  def get_image_header
    building.present? ? building.get_image_header : ''
  end

  def self.search_by(building_id)
    departments = []
    departments = where(building_id: building_id) if building_id.present?
    [['', '--']] + departments.map { |d| [d.id, d.name] }
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'building')]
  end

  def verify_assignment
    total_users = users.map{|u| u.status.to_i}.sum
    total_users > 0 ? true : false
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:building).order("#{sort_column} #{sort_direction}").references(:building)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == 'building' ? 'buildings.name' : "departments.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("departments.code LIKE ? OR departments.name LIKE ? OR buildings.name LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code name building status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |department|
        a = Array.new
        a << department.code
        a << department.name
        a << department.building_name
        a << h.type_status(department.status)
        csv << a
      end
    end
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    department = Hash.new
    CORRELATIONS.each do |origin, destination|
      department.merge!({ destination => record[origin] })
    end
    b = Building.find_by_code(record['UNIDAD'])
    b.present? && department.present? && new(department.merge!({ building: b })).save
  end
end
