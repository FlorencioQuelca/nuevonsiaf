class Supplier < ActiveRecord::Base
  has_many :note_entries
  has_many :ingresos

  validates :name, presence: true, uniqueness: true

  def self.search_supplier(q)
    where("name LIKE ?", "%#{q}%")
  end

  def self.get_id(name)
    supplier = where(name: name)
    if supplier.present?
      supplier.first.id
    else
      supplier = Supplier.new(name: name)
      supplier.save
      supplier.id
    end
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'name'), h.get_column(self, 'nit'), h.get_column(self, 'telefono'), h.get_column(self, 'contacto')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("name LIKE ? OR nit LIKE ? OR telefono LIKE ? OR contacto LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end
end
