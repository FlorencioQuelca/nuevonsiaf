class AddDerecognisedToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :derecognised, :datetime
  end
end
