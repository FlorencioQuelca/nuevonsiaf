class AddAmountDeliveredToSubarticleRequest < ActiveRecord::Migration
  def change
    add_column :subarticle_requests, :amount_delivered, :integer
    change_column :requests, :delivered, :string
    rename_column :requests, :delivered, :status
  end
end
