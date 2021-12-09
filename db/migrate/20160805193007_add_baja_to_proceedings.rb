class AddBajaToProceedings < ActiveRecord::Migration
  def change
    add_column :proceedings, :baja_logica, :boolean, null: false, default: false
  end
end
