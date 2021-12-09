class AddInvalidateToKardexPrices < ActiveRecord::Migration
  def change
    add_column :kardex_prices, :invalidate, :boolean, default: false
  end
end
