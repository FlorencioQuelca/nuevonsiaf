class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :code, limit: 50
      t.text :description
      t.belongs_to :auxiliary, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
