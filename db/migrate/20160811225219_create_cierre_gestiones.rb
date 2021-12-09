class CreateCierreGestiones < ActiveRecord::Migration
  def change
    create_table :cierre_gestiones do |t|
      t.decimal :actualizacion_gestion, precision: 10, scale: 2
      t.decimal :depreciacion_gestion, precision: 10, scale: 2
      t.decimal :indice_ufv, precision: 6, scale: 5
      t.references :asset, index: true, foreign_key: true
      t.references :gestion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
