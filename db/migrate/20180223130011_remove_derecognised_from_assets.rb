class RemoveDerecognisedFromAssets < ActiveRecord::Migration
  def change
    remove_column :assets, :derecognised, :datetime
    remove_column :assets, :description_decline, :text
    remove_column :assets, :reason_decline, :text
    remove_column :assets, :decline_user_id, :integer
  end
end
