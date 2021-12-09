class AddColumnToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :delivered, :boolean, default: false
    add_column :requests, :delivery_date, :timestamp
  end
end
