class AddNotaEntregaNumeroToIngresos < ActiveRecord::Migration
  def up
    add_column :ingresos, :nota_entrega_numero, :integer
    rename_column :ingresos, :fecha, :nota_entrega_fecha
    rename_column :ingresos, :c31, :c31_numero
    add_column :ingresos, :c31_fecha, :date
    change_column :ingresos, :factura_numero, :string
    change_column :ingresos, :factura_autorizacion, :string
    add_reference :ingresos, :user, index: true, foreign_key: true
  end

  def down
    remove_column :ingresos, :nota_entrega_numero
    rename_column :ingresos, :nota_entrega_fecha, :fecha
    rename_column :ingresos, :c31_numero, :c31
    remove_column :ingresos, :c31_fecha
    change_column :ingresos, :factura_numero, :integer
    change_column :ingresos, :factura_autorizacion, :integer
    remove_reference :ingresos, :user, index: true, foreign_key: true
  end
end
