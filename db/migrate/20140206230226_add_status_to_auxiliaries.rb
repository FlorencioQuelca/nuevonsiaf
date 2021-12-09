class AddStatusToAuxiliaries < ActiveRecord::Migration
  def change
    add_column :auxiliaries, :status, :string
  end
end
