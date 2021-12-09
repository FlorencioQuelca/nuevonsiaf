class AddPrecioToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :precio, :float
  end
end
