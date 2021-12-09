class AddSeguroToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :seguro, :boolean, null: false, default: false
  end
end
