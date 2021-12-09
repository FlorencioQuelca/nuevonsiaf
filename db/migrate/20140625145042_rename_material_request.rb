class RenameMaterialRequest < ActiveRecord::Migration
  def change
    rename_column :material_requests, :material_id, :subarticle_id
    rename_table :material_requests, :subarticle_requests
  end
end
