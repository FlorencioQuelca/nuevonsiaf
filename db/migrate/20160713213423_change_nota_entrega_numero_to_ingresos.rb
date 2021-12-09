class ChangeNotaEntregaNumeroToIngresos < ActiveRecord::Migration
  def up
    change_column :ingresos, :nota_entrega_numero, :string
  end

  def down
    change_column :ingresos, :nota_entrega_numero, :integer
  end
end
