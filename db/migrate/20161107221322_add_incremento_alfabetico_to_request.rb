class AddIncrementoAlfabeticoToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :incremento_alfabetico, :string
    add_column :requests, :observacion, :string
  end
end
