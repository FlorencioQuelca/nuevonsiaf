class Ubicacion < ActiveRecord::Base

  validates :abreviacion, presence: true
  validates :descripcion, presence: true

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'abreviacion'), h.get_column(self, 'descripcion')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("abreviacion LIKE ? OR descripcion LIKE ?", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(abreviacion descripcion)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |department|
        a = Array.new
        a << department.abreviacion
        a << department.descripcion
        csv << a
      end
    end
  end

  def detalle
    [abreviacion, descripcion].compact.join(' - ')
  end
end
