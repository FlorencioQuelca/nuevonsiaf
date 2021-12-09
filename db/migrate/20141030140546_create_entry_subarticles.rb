class CreateEntrySubarticles < ActiveRecord::Migration
  def change
    create_table :entry_subarticles do |t|
      t.integer :amount
      t.decimal :unit_cost, precision: 10, scale: 2
      t.decimal :total_cost, precision: 10, scale: 2
      t.integer :invoice
      t.date :date
      t.belongs_to :subarticle, index: true

      t.timestamps
    end
  end
end
