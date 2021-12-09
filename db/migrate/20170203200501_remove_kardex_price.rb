class RemoveKardexPrice < ActiveRecord::Migration
  def up
    drop_table :kardex_prices
  end
  
  def down
    create_table :kardex_prices do |t|
      t.integer :input_quantities, null: false, default: 0
      t.integer :output_quantities, null: false, default: 0
      t.integer :balance_quantities, null: false, default: 0
      t.decimal :unit_cost, precision: 10, scale: 2, null: false, default: 0
      t.decimal :input_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :output_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :balance_amount, precision: 10, scale: 2, null: false, default: 0
      t.belongs_to :kardex, index: true

      t.timestamps
    end
  end
end
