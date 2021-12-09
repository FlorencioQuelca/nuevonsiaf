class AddTotalAndUserIdToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :total, :decimal, precision: 10, scale: 2
    add_column :note_entries, :user_id, :integer
  end
end
