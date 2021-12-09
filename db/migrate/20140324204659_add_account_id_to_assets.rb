class AddAccountIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :account, index: true
  end
end
