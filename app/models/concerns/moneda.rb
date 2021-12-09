module Moneda
  extend ActiveSupport::Concern

  module ClassMethods
    # Redondear un número a dos (2) decimales
    def redondear(numero, decimal = 2)
      (numero * (10 ** decimal)).round / (10 ** decimal).to_f
    end
  end

  # Redondear un número a dos (2) decimales
  def redondear(numero, decimal = 2)
    self.class.redondear(numero, decimal)
  end
end
