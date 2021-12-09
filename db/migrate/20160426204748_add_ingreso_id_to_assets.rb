class AddIngresoIdToAssets < ActiveRecord::Migration
  def change
    add_reference :assets, :ingreso, index: true, foreign_key: true
  end
end
