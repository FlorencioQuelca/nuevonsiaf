class AddReingresoToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :reingreso, :boolean, default: false, null: false
  end
end
