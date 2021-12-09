class ChangeCodeToAccounts < ActiveRecord::Migration
  def up
    change_column :accounts, :code, :integer
  end

  def down
    change_column :accounts, :code, :string, limit: 50
  end
end
