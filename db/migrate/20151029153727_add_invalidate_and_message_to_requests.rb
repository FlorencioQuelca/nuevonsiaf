class AddInvalidateAndMessageToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :invalidate, :boolean, default: false
    add_column :requests, :message, :string, default: nil
  end
end
