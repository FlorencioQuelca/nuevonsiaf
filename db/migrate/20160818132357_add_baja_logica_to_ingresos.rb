class AddBajaLogicaToIngresos < ActiveRecord::Migration
  def up
    change_column_default :ingresos, :baja_logica, false
    Ingreso.unscoped.where(baja_logica: nil).update_all(baja_logica: false)
  end

  def down
    change_column_default :ingresos, :baja_logica, nil
  end
end
