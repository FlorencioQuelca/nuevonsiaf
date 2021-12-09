class AddIncrementoToSubarticles < ActiveRecord::Migration
  def up
    add_column :subarticles, :incremento, :integer
    change_column :subarticles, :code, :integer
  end

  def down
    remove_column :subarticles, :incremento
    change_column :subarticles, :code, :string
  end
end
