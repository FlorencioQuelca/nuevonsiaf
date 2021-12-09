class AddImageToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :header, :string
    add_column :entities, :footer, :string
  end
end
