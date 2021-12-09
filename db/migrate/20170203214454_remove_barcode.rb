class RemoveBarcode < ActiveRecord::Migration
  def up
    drop_table :barcodes
  end

  def down
    create_table :barcodes do |t|
      t.string :code
      t.belongs_to :entity, index: true
      t.integer :status, index: true

      t.timestamps
    end
  end
end
