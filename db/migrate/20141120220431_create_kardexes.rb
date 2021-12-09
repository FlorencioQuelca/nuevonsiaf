class CreateKardexes < ActiveRecord::Migration
  def change
    create_table :kardexes do |t|
      t.date :kardex_date
      t.string :invoice_number, default: 0
      t.integer :order_number
      t.string :detail
      t.belongs_to :subarticle, index: true

      t.timestamps
    end
  end
end
