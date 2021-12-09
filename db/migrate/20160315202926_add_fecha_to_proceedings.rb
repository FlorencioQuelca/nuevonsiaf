class AddFechaToProceedings < ActiveRecord::Migration
  def up
    add_column :proceedings, :fecha, :date
    Proceeding.unscoped.update_all('fecha = created_at')
  end

  def down
    remove_column :proceedings, :fecha
  end
end
