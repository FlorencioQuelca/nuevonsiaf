class AddMaterialIdToSubarticles < ActiveRecord::Migration
  def change
    add_reference :subarticles, :material, index: true, foreign_key: true
  end
end
