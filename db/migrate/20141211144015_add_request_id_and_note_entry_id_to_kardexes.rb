class AddRequestIdAndNoteEntryIdToKardexes < ActiveRecord::Migration
  def change
    add_reference :kardexes, :request, index: true
    add_reference :kardexes, :note_entry, index: true
  end
end
