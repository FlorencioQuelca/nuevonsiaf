class AssetAccountSerializer < ActiveModel::Serializer
  self.root = false
  attributes  :id, :codigo, :descripcion, :auxiliar, :precio, :url

  def codigo
    object.code
  end

  def descripcion
    object.description
  end

  def auxiliar
    object.name
  end

  def url
    { show: asset_path(object) }
  end
end