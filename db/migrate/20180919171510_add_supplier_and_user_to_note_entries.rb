class AddSupplierAndUserToNoteEntries < ActiveRecord::Migration
  def change
    add_foreign_key :note_entries, :suppliers
    add_foreign_key :note_entries, :users
  end
end
