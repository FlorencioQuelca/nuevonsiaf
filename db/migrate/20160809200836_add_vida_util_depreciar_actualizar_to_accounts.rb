class AddVidaUtilDepreciarActualizarToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :vida_util, :integer, null: false, default: 0
    add_column :accounts, :depreciar, :boolean, null: false, default: false
    add_column :accounts, :actualizar, :boolean, null: false, default: false
  end
end
