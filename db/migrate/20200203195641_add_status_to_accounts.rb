class AddStatusToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :status, :string, default: '1'
  end
end
