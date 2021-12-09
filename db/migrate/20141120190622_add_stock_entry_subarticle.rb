class AddStockEntrySubarticle < ActiveRecord::Migration
  def change
    add_column :entry_subarticles, :stock, :integer, default: 0, null: false
    add_column :entry_subarticles, :note_entry_id, :integer
  end
end
