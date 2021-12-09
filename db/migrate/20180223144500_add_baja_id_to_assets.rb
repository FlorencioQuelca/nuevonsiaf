class AddBajaIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :baja, index: true, foreign_key: true
    add_column :bajas, :motivo, :string
    add_column :bajas, :fecha_documento, :date
  end
end
