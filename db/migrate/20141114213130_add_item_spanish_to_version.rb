class AddItemSpanishToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :item_spanish, :string
  end
end
