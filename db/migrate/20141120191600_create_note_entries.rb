class CreateNoteEntries < ActiveRecord::Migration
  def change
    create_table :note_entries do |t|
      t.integer :delivery_note_number
      t.date :delivery_note_date
      t.integer :invoice_number
      t.date :invoice_date
      t.belongs_to :supplier, index: true

      t.timestamps
    end
  end
end
