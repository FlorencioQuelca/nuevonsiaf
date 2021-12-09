class AddStatusToBuilding < ActiveRecord::Migration
  def change
    add_column :buildings, :status, :string
  end
end
