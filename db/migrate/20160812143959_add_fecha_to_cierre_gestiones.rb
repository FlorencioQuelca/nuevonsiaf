class AddFechaToCierreGestiones < ActiveRecord::Migration
  def change
    add_column :cierre_gestiones, :fecha, :date
  end
end
