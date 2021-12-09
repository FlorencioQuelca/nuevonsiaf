class AddAssetsCount < ActiveRecord::Migration
  def self.up
    add_column :users, :assets_count, :integer, default: 0

    User.reset_column_information
    User.all.each do |u|
      User.reset_counters(u.id, :assets)
    end
  end

  def self.down
    remove_column :users, :assets_count
  end
end
