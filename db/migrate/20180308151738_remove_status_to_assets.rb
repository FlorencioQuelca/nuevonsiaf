class RemoveStatusToAssets < ActiveRecord::Migration
  def change
    remove_column :assets, :status, :string, limit: 2
  end
end
