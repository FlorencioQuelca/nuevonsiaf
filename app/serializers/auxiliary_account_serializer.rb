class AuxiliaryAccountSerializer < ActiveModel::Serializer

  self.root = false
  attributes  :id, :codigo, :nombre, :cantidad_activos, :monto_activos, :url

  def codigo
    object.code
  end

  def nombre
    object.name
  end

  def url
    { show: auxiliary_path(object) }
  end
end
