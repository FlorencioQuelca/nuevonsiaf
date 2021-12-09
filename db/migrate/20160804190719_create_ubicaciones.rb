class CreateUbicaciones < ActiveRecord::Migration
  def change
    create_table :ubicaciones do |t|
      t.string :abreviacion
      t.string :descripcion

      t.timestamps null: false
    end
  end
end
