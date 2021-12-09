class AddBarcodeToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :barcode, :string
  end
end
