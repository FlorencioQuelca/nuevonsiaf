class AddNroNotaIngresoToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :nro_nota_ingreso, :integer, default: 0
  end
end
