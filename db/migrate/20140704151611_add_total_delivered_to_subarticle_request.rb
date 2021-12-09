class AddTotalDeliveredToSubarticleRequest < ActiveRecord::Migration
  def change
    add_column :subarticle_requests, :total_delivered, :integer, default: 0
  end
end
