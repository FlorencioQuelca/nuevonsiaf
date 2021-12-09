class AddObservacionToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :observacion, :string
  end
end
