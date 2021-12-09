class AddColumnasPlantillasToIngresos < ActiveRecord::Migration
  def change
    add_column :ingresos, :documento_id, :integer, unique: true, index: true
    add_column :ingresos, :documento_cite, :string

  end
end
