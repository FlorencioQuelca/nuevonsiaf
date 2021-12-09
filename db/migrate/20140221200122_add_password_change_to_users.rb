class AddPasswordChangeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_change, :boolean, null: false, default: false
  end
end
