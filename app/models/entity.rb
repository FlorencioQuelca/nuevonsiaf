class Entity < ActiveRecord::Base

  mount_uploader :header, ImageUploader
  mount_uploader :footer, ImageUploader

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :acronym, presence: true

  has_paper_trail

  has_many :buildings

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'acronym')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
      else
        array = array.where("code LIKE ? OR name LIKE ? OR acronym LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    column_names = ['code', 'name', 'acronym']
    CSV.generate do |csv|
      csv << column_names.map { |c| self.human_attribute_name(c) }
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def get_header
    header.present? ? header_url.to_s : ''
  end

  def get_image_header
    get_header
  end

  def get_footer
    footer.present? ? footer_url.to_s : ''
  end

  def get_image_footer
    get_footer
  end
end
