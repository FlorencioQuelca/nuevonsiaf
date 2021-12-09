class ChangeColumnsIntoEntrySubarticlesToDecimal < ActiveRecord::Migration
  def up
    change_column :entry_subarticles, :amount, :decimal, precision: 10, scale: 4
    change_column :entry_subarticles, :unit_cost, :decimal, precision: 10, scale: 4
  end

  def down
    change_column :entry_subarticles, :amount, :float
    change_column :entry_subarticles, :unit_cost, :float
  end
end
