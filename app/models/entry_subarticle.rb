class EntrySubarticle < ActiveRecord::Base
  default_scope {where(invalidate: false).order(:created_at)}

  belongs_to :subarticle
  belongs_to :note_entry

  #validates :amount, :invoice, presence: true, numericality: { only_integer: true, greater_than: 0 }
  #validates :unit_cost, :total_cost, presence: true, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0, less_than: 10000000 }

  before_create :set_stock_value
  before_create :set_date_value

  # Anula las entradas de subartículos, estableciendo el campo invalidate a true
  def self.invalidate_entries
    update_all(invalidate: true)
  end

  def self.replicate
    all.map { |e| e.dup }
  end

  def self.years_not_closed
    years = select(:date).where('stock > ?', 0)
    years = years.map { |e| e.date.present? ? e.date.year : nil }
    years.compact.uniq
  end

  def subarticle_name
    subarticle.present? ? subarticle.description : ''
  end

  def subarticle_code
    subarticle.present? ? subarticle.code : ''
  end

  def subarticle_unit
    subarticle.present? ? subarticle.unit : ''
  end

  def decrease_amount
    if self.stock > 0
      self.stock = self.stock - 1
      self.save
    else
      Rails.logger.info "No se pudo decrementar porque no es mayor a cero"
    end
  end

  def decrementando_stock(cantidad)
    if self.stock >= cantidad
      self.stock = self.stock - cantidad
      self.save
    else
      Rails.logger.info "No se pudo decrementar porque no es mayor a la cantidad solicitada"
    end
  end

  def set_date_value
    if note_entry.present?
      self.date = note_entry.note_entry_date
    end
  end

  def material_description
    subarticle.present? ? subarticle.material_description : '' 
  end

  private

  def set_stock_value
    self.stock = amount
  end

end
