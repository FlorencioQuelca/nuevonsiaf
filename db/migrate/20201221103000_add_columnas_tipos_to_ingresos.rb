class AddColumnasTiposToIngresos < ActiveRecord::Migration
  def up
    add_column :ingresos, :tipo_ingreso, :string
    add_column :ingresos, :entidad_donante, :string

  end

  def down
    remove_column :ingresos, :tipo_ingreso, :string
    remove_column :ingresos, :entidad_donante, :string
    remove_column :ingresos, :documento_respaldo, :string
    remove_column :ingresos, :documento_respaldo_fecha, :string
  end
end
