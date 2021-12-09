class Auxiliary < ActiveRecord::Base
  include ImportDbf, Migrated, VersionLog, ManageStatus

  CORRELATIONS = {
    'CODAUX' => 'code',
    'NOMAUX' => 'name'
  }

  belongs_to :account
  has_many :assets

  with_options if: :is_not_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: :account_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :name, :account_id, presence: true
  end

  with_options if: :is_migrate? do |m|
    m.validates :code, presence: true, uniqueness: { scope: :account_id }, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    m.validates :account_id, presence: true
  end

  has_paper_trail ignore: [:status, :updated_at]

  def account_code
    account.present? ? account.code : ''
  end

  def account_name
    account.present? ? account.name : ''
  end

  def account_vida_util
    account.present? ? account.vida_util : 0
  end

  def verify_assignment
    assets.present?
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = includes(:account).order("#{sort_column} #{sort_direction}").references(:account)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = search_column == 'account' ? 'accounts.name' : "auxiliaries.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("auxiliaries.code LIKE ? OR auxiliaries.name LIKE ? OR accounts.name LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(code name account status)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |auxiliary|
        a = auxiliary.attributes.values_at(*columns)
        a.pop(2)
        a.push(auxiliary.account_name, h.type_status(auxiliary.status))
        csv << a
      end
    end
  end

  private

  ##
  # Guarda en la base de datos de acuerdo a la correspondencia de campos.
  def self.save_correlations(record)
    aux = { is_migrate: true }
    CORRELATIONS.each do |origin, destination|
      aux.merge!({ destination => record[origin] })
    end
    a = Account.find_by_code(record['CODCONT'])
    a.present? && aux.present? && new(aux.merge!({ account: a })).save
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'code'), h.get_column(self, 'name'), h.get_column(self, 'account')]
  end
end
