class ChangeCodeToAuxiliaries < ActiveRecord::Migration
  def up
    change_column :auxiliaries, :code, :integer
  end

  def down
    change_column :auxiliaries, :code, :string, limit: 50
  end
end
