class AddInvoiceAutorizacionC31ToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :invoice_autorizacion, :string
    add_column :note_entries, :c31, :string
  end
end
