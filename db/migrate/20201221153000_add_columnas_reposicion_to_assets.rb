class AddColumnasReposicionToAssets < ActiveRecord::Migration
  def up
    add_reference :assets, :asset, index: true

  end

  def down
    remove_reference :assets, :asset
  end
end
