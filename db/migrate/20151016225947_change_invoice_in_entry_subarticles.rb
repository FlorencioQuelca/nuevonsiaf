class ChangeInvoiceInEntrySubarticles < ActiveRecord::Migration
  def change
    change_column :entry_subarticles, :invoice, :string
    change_column_default :entry_subarticles, :invoice, ''
  end
end
