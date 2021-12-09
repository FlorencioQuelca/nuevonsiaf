class CreateAssetProceedings < ActiveRecord::Migration
  def change
    create_table :asset_proceedings do |t|
      t.belongs_to :proceeding, index: true
      t.belongs_to :asset, index: true

      t.timestamps
    end
  end
end
