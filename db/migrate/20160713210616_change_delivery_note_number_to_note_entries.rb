class ChangeDeliveryNoteNumberToNoteEntries < ActiveRecord::Migration
  def up
    change_column :note_entries, :delivery_note_number, :string
  end

  def down
    change_column :note_entries, :delivery_note_number, :integer
  end
end
