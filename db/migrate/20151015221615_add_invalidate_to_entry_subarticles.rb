class AddInvalidateToEntrySubarticles < ActiveRecord::Migration
  def change
    add_column :entry_subarticles, :invalidate, :boolean, default: false
  end
end
