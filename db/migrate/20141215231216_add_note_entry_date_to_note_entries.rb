class AddNoteEntryDateToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :note_entry_date, :date
  end
end
