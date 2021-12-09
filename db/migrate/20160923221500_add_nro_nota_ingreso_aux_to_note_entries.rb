class AddNroNotaIngresoAuxToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :incremento_alfabetico, :string, default: nil
  end
end
