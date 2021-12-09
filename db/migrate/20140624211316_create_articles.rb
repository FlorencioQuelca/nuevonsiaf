class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :code
      t.string :description
      t.string :status
      t.belongs_to :material, index: true

      t.timestamps
    end
  end
end
