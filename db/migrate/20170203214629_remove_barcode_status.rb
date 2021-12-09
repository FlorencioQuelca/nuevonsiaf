class RemoveBarcodeStatus < ActiveRecord::Migration
  def up
    drop_table :barcode_statuses
  end

  def down
    create_table :barcode_statuses, {id: false} do |t|
      t.integer :status
      t.string :description

      t.timestamps
    end
    execute "ALTER TABLE barcode_statuses ADD PRIMARY KEY (status);"
  end
end
