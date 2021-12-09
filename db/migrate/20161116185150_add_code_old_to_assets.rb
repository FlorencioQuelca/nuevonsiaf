class AddCodeOldToAssets < ActiveRecord::Migration
  def change
    rename_column :assets, :codigo_antiguo, :code_old
  end
end
