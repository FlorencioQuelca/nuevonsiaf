module Almacenes
  class ProveedorSerializer < ActiveModel::Serializer
    attributes :id, :name, :nit, :telefono, :contacto
  end
end