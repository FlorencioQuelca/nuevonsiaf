class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, limit: 230, null: false, default: ''
    add_column :users, :code,     :string, limit: 230
    add_column :users, :name,     :string, limit: 230
    add_column :users, :title,    :string, limit: 230
    add_column :users, :ci,       :integer
    add_column :users, :phone,    :string, limit: 230
    add_column :users, :mobile,   :string, limit: 230
    add_column :users, :status,   :string, limit: 2

    add_index :users, :username
  end
end
