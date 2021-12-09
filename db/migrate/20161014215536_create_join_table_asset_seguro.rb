class CreateJoinTableAssetSeguro < ActiveRecord::Migration
  def change
    create_join_table :assets, :seguros do |t|
      t.index [:asset_id, :seguro_id]
      t.index [:seguro_id, :asset_id]
    end
  end
end
