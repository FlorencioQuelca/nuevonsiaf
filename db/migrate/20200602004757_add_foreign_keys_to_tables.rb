class AddForeignKeysToTables < ActiveRecord::Migration
  def change
    add_foreign_key :seguros, :users
    add_foreign_key :seguros, :suppliers
    add_foreign_key :assets_seguros, :assets
    add_foreign_key :assets_seguros, :seguros
    add_foreign_key :proceedings, :users
    add_foreign_key :proceedings, :users, column: :admin_id, primary_key: "id"
    add_foreign_key :assets, :auxiliaries
    add_foreign_key :assets, :users
    add_foreign_key :bajas, :users
    add_foreign_key :auxiliaries, :accounts
    add_foreign_key :departments, :buildings
    add_foreign_key :buildings, :entities
    add_foreign_key :asset_proceedings, :proceedings
    add_foreign_key :asset_proceedings, :assets
  end
end
