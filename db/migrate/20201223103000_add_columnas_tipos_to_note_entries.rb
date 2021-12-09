class AddColumnasTiposToNoteEntries < ActiveRecord::Migration
  def up
    add_column :note_entries, :tipo_ingreso, :string
    add_column :note_entries, :entidad_donante, :string

  end

  def down
    remove_column :note_entries, :tipo_ingreso, :string
    remove_column :note_entries, :entidad_donante, :string
  end
end
