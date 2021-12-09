class ChangeCodeToDepartments < ActiveRecord::Migration
  def up
    change_column :departments, :code, :integer
  end

  def down
    change_column :departments, :code, :string, limit: 50
  end
end
