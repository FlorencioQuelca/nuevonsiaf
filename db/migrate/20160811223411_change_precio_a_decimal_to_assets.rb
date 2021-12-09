class ChangePrecioADecimalToAssets < ActiveRecord::Migration
  def up
    Asset.where(precio: nil).update_all(precio: 0)
    change_column :assets, :precio, :decimal, precision: 10, scale: 2, default: 0 , null: false
  end

  def down
    change_column :assets, :precio, :float
  end
end
