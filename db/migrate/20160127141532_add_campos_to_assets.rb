class AddCamposToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :detalle, :string
    add_column :assets, :medidas, :string
    add_column :assets, :material, :string
    add_column :assets, :color, :string
    add_column :assets, :marca, :string
    add_column :assets, :modelo, :string
    add_column :assets, :serie, :string
  end
end
