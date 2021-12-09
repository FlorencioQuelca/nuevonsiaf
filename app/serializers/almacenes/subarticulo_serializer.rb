module Almacenes
  class SubarticuloSerializer < ActiveModel::Serializer
    attributes :id, :code, :description, :unit
  end
end