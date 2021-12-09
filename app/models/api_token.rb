class ApiToken < ActiveRecord::Base
  include VersionLog, ManageStatus
  
  validates :email, presence: true
  validates :nombre, presence: true

  has_paper_trail ignore: [:status, :updated_at]

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'email'), h.get_column(self, 'nombre'), h.get_column(self, 'token'), h.get_column(self, 'fecha_expiracion')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("nombre LIKE ? OR email LIKE ?", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def verify_assignment
    false
  end
end
