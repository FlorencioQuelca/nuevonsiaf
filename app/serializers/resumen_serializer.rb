class ResumenSerializer < ActiveModel::Serializer
  self.root = false
  attributes :nombre, :cantidad, :sumatoria

  def cantidad
    try_metodo("cantidad")
  end

  def try_metodo(metodo)
    object.send(metodo.to_sym) if object.respond_to?(metodo.to_sym)
  end
end
