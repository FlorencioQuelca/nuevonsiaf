class AddStateToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :state, :integer
  end
end
