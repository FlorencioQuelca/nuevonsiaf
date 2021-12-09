class RemoveDocumento < ActiveRecord::Migration
  def up
    drop_table :documentos
  end

  def down
    create_table :documentos do |t|
      t.string :titulo
      t.text :contenido
      t.string :formato
      t.string :etiquetas

      t.timestamps
    end
  end
end
