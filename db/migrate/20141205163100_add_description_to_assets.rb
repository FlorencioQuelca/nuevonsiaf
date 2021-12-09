class AddDescriptionToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :description_decline, :text
    add_column :assets, :reason_decline, :text
    add_column :assets, :decline_user_id, :integer
    drop_table :declines
  end
end
