class CreateGestiones < ActiveRecord::Migration
  def change
    create_table :gestiones do |t|
      t.string :anio, null: false, default: ''
      t.boolean :cerrado, null: false, default: false
      t.datetime :fecha_cierre

      t.timestamps null: false
    end
  end
end
