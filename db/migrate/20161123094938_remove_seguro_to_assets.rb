class RemoveSeguroToAssets < ActiveRecord::Migration
  def change
    remove_column :assets, :seguro, :string
  end
end
