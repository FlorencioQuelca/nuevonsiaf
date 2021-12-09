class AddIncrementoAlfabeticoToIngresos < ActiveRecord::Migration
  def change
    add_column :ingresos, :incremento_alfabetico, :string
    add_column :ingresos, :observacion, :string
  end
end
