module CodeNumber
  extend ActiveSupport::Concern

  included do
    validate :establecer_barcode, on: :create
  end

  def establecer_barcode
    if material.present? && self.incremento.present?
      self.barcode = "#{material.code}#{self.incremento}"
      self.code = self.barcode.to_i
    end
  end
end
