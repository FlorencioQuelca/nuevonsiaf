class AlterCiToUsers < ActiveRecord::Migration
  def up
    change_column :users, :ci, :string
  end

  def down
    change_column :users, :ci, :integer
  end
end
