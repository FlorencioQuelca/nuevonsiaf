class ChangeInvoiceNumberToNoteEntries < ActiveRecord::Migration
  def change
    change_column :note_entries, :invoice_number, :string
    change_column_default :note_entries, :invoice_number, ''
  end
end
