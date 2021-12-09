class CreateSubarticles < ActiveRecord::Migration
  def change
    create_table :subarticles do |t|
      t.string :code
      t.string :description
      t.string :unit
      t.string :status
      t.belongs_to :article, index: true

      t.timestamps
    end
  end
end
