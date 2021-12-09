class CreateIngresos < ActiveRecord::Migration
  def change
    create_table :ingresos do |t|
      t.integer :numero
      t.date :fecha
      t.integer :factura_numero
      t.integer :factura_autorizacion
      t.date :factura_fecha
      t.references :supplier, index: true, foreign_key: true
      t.string :c31
      t.boolean :baja_logica
      t.decimal :total, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end
