class CreateDocumentos < ActiveRecord::Migration
  def change
    create_table :documentos do |t|
      t.string :titulo
      t.text :contenido
      t.string :formato
      t.string :etiquetas

      t.timestamps
    end
  end
end
