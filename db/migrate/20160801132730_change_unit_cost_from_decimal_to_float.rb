class ChangeUnitCostFromDecimalToFloat < ActiveRecord::Migration
  def up
    change_column :entry_subarticles, :unit_cost, :float
  end

  def down
    change_column :entry_subarticles, :unit_cost, :decimal, precision: 10, scale: 2, default: 0 , null: false
  end
end
