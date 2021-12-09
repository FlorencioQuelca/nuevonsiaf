class ChangeColumnsFromMaterials < ActiveRecord::Migration
  def change
    add_column :materials, :status, :string, limit: 2
    remove_column :materials, :unit, :string
    remove_column :materials, :name, :string
    change_column :materials, :description, :string
  end
end
