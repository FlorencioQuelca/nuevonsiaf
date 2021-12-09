class AddObservationToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :observation, :text
  end
end
