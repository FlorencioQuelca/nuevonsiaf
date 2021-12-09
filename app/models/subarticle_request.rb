class SubarticleRequest < ActiveRecord::Base
  default_scope {where(invalidate: false)}
  
  belongs_to :subarticle
  belongs_to :request

  def self.invalidate_subarticles
    update_all(invalidate: true)
  end

  # Se entrega todos los subartículos solicitados haciendo la resta al stock
  def self.entregar_subarticulos
    all.each do |subarticle_request|
      subarticle_request.entregar_subarticulo
    end
  end

  # Realiza la iteracion de las solicitudes de subarticulo con la cantidad a
  # entregar.
  def self.validar_cantidades(cantidades_subarticulo)
    resultado = []
    all.each do |solic_subart|
      cantidad_subarticulo = cantidades_subarticulo.select { |s| s['id'] == solic_subart.id.to_s }
      resultado << solic_subart.validar_cantidad(cantidad_subarticulo.first)
    end
    resultado
  end

  # Realizar la resta del stock al subartículo
  def entregar_subarticulo
    subarticle.entregar_subarticulo(amount_delivered)
    incremento_total_delivered(amount_delivered)
  end

  def subarticle_unit
    subarticle.present? ? subarticle.unit : ''
  end

  def subarticle_description
    subarticle.present? ? subarticle.description : ''
  end

  def subarticle_code
    subarticle.present? ? subarticle.code : ''
  end

  def subarticle_barcode
    subarticle.present? ? subarticle.barcode : ''
  end

  # Obtiene el stock disponible del subarticulo asociado.
  def subarticle_stock
    subarticle.present? ? subarticle.stock : 0
  end

  def self.get_subarticle(subarticle_id)
    where(subarticle_id: subarticle_id).first
  end

  def increase_total_delivered
    increase = total_delivered + 1
    update_attribute('total_delivered', increase)
  end

  def incremento_total_delivered(cantidad)
    update_attribute('total_delivered', cantidad)
  end

  # Verificación de la cantidad a entregar sea mayor o igual a 0, sea menor o
  # igual al stock y a la cantidad solicitada
  def validar_cantidad(cantidad_subarticulo)
    cantidad_entregar = cantidad_subarticulo['cantidad'].to_i
    verificacion = true
    mensaje = ''
    if cantidad_entregar > subarticle.stock
      mensaje = 'La cantidad a entregar es mayor al stock disponible.'
      verificacion = false
    end
    { id: id, verificacion: verificacion, mensaje: mensaje }
  end

  def self.is_delivered?
    where('total_delivered < amount_delivered').present?
  end
end
