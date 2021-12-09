class AddProcesoToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :proceso, :string
    add_column :assets, :observaciones, :string
  end
end
