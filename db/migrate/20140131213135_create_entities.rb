class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :code,    limit: 50
      t.string :name,    limit: 230
      t.string :acronym, limit: 50

      t.timestamps
    end
  end
end
