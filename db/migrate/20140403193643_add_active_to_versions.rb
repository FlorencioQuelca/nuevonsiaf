class AddActiveToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :active, :boolean, default: true
  end
end
