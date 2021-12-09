class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :code, limit: 50
      t.string :name
      t.string :unit
      t.text :description

      t.timestamps
    end
  end
end
