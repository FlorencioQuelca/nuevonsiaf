module Almacenes
  class IngresoItemSerializer < ActiveModel::Serializer
    has_one :subarticle, serializer: Almacenes::SubarticuloSerializer

    attributes :id, :amount, :unit_cost, :total_cost, :subarticle, :note_entry_id
  end
end