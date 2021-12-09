class AddStatusToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :status, :string, limit: 2
  end
end
