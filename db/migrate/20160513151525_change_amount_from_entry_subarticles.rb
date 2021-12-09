class ChangeAmountFromEntrySubarticles < ActiveRecord::Migration
  def up
    change_column :entry_subarticles, :amount, :float
  end

  def down
    change_column :entry_subarticles, :amount, :integer
  end
end
