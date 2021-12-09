class AddDeliveryNoteNumberToKardexes < ActiveRecord::Migration
  def change
    add_column :kardexes, :delivery_note_number, :string
  end
end
