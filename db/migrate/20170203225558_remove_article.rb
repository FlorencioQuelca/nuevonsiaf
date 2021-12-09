class RemoveArticle < ActiveRecord::Migration
  def up
    drop_table :articles
  end

  def down
    create_table :articles do |t|
      t.string :code
      t.string :description
      t.string :status
      t.belongs_to :material, index: true
      t.timestamps
    end
  end
end
