class AddColumnsToSubarticle < ActiveRecord::Migration
  def change
    add_column :subarticles, :amount, :integer
    add_column :subarticles, :minimum, :integer
    add_column :subarticles, :barcode, :string
  end
end
