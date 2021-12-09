class AddSubarticleAndRequestToSubarticleRequests < ActiveRecord::Migration
  def change
    add_foreign_key :subarticle_requests, :subarticles
    add_foreign_key :subarticle_requests, :requests
  end
end
