class AddDescuentoToNoteEntries < ActiveRecord::Migration
  def up
    add_column :note_entries, :subtotal, :decimal, precision: 10, scale: 2, default: 0
    add_column :note_entries, :descuento, :decimal, precision: 10, scale: 2, default: 0

    NoteEntry.update_all('subtotal=total - descuento')
  end

  def down
    remove_column :note_entries, :subtotal
    remove_column :note_entries, :descuento
  end
end
