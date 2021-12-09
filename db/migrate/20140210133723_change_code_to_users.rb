class ChangeCodeToUsers < ActiveRecord::Migration
  def up
    change_column :users, :code, :integer
  end

  def down
    change_column :users, :code, :string, limit: 50
  end
end
