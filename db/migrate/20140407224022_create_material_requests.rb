class CreateMaterialRequests < ActiveRecord::Migration
  def change
    create_table :material_requests do |t|
      t.belongs_to :material, index: true
      t.belongs_to :request, index: true
      t.integer :amount
    end
  end
end
