class AddInvalidateToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :invalidate, :boolean, default: false
    add_column :note_entries, :message, :string, default: nil
  end
end
