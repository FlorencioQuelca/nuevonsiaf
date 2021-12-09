class CreateBuildings < ActiveRecord::Migration
  def change
    create_table :buildings do |t|
      t.string :code, limit: 50
      t.string :name, limit: 230
      t.belongs_to :entity, index: true

      t.timestamps
    end

    add_index :buildings, :code, unique: true
  end
end
