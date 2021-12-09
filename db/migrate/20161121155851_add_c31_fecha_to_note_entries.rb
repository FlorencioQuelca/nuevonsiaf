class AddC31FechaToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :c31_fecha, :date
  end
end
