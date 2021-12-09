class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :code, limit: 50
      t.string :name, limit: 230

      t.timestamps
    end
  end
end
