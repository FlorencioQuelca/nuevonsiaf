class AddInvalidateToSubarticleRequests < ActiveRecord::Migration
  def change
    add_column :subarticle_requests, :invalidate, :boolean, default: false
  end
end
