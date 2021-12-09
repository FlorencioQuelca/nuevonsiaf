class AddColumnasPlantillasToBajas < ActiveRecord::Migration
  def change
    add_column :bajas, :documento_id, :integer, unique: true, index: true
    add_column :bajas, :documento_cite, :string

  end
end
