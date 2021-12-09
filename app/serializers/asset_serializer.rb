class AssetSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :code, :description, :detalle, :barcode, :observaciones, :precio, :cuenta, :urls

  def urls
    { show: asset_path(object) }
  end

  def cuenta
    try_metodo("cuenta")
  end

  def try_metodo(metodo)
    object.send(metodo.to_sym) if object.respond_to?(metodo.to_sym)
  end
end
