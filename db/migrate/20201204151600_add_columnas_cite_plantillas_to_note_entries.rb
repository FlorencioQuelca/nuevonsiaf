class AddColumnasCitePlantillasToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :documento_cite, :string

  end
end
