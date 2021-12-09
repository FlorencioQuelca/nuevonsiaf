class AddSubarticleAndNoteEntryToEntrySubarticles < ActiveRecord::Migration
  def change
    add_foreign_key :entry_subarticles, :subarticles
    add_foreign_key :entry_subarticles, :note_entries
  end
end
