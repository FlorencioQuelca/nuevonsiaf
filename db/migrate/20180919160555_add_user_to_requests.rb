class AddUserToRequests < ActiveRecord::Migration
  def change
    add_foreign_key :requests, :users
    add_foreign_key :requests, :users, column: 'admin_id'
  end
end
