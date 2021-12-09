class ChangeActualizacionGestionToCierreGestiones < ActiveRecord::Migration
  def up
    change_column :cierre_gestiones, :actualizacion_gestion, :decimal, precision: 19, scale: 6
    change_column :cierre_gestiones, :depreciacion_gestion, :decimal, precision: 19, scale: 6
  end

  def down
    change_column :cierre_gestiones, :actualizacion_gestion, :decimal, precision: 10, scale: 2
    change_column :cierre_gestiones, :depreciacion_gestion, :decimal, precision: 10, scale: 2
  end
end
