class AddInvalidateToKardex < ActiveRecord::Migration
  def change
    add_column :kardexes, :invalidate, :boolean, default: false
  end
end
