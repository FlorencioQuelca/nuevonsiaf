class Ufv < ActiveRecord::Base

  include UfvImportar

  validates :fecha, presence: true, uniqueness: true
  validates :valor, presence: true

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'fecha'), h.get_column(self, 'valor')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("fecha LIKE ? OR valor LIKE ?", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(fecha valor)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |ufv|
        a = Array.new
        a << ufv.fecha
        a << ufv.valor
        csv << a
      end
    end
  end

  def self.indice(fecha = Date.today)
    where(fecha: fecha).take.valor rescue 0
  end

end
