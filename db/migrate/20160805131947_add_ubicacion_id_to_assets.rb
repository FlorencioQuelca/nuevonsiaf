class AddUbicacionIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :ubicacion, index: true, foreign_key: true
  end
end
