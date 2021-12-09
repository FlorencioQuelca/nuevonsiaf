class CreateBarcodeStatuses < ActiveRecord::Migration
  def up
    create_table :barcode_statuses, {id: false} do |t|
      t.integer :status
      t.string :description

      t.timestamps
    end
    execute "ALTER TABLE barcode_statuses ADD PRIMARY KEY (status);"
  end

  def down
    drop_table :barcode_statuses
  end
end
