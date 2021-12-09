class AddSeguroIdToSeguros < ActiveRecord::Migration
  def change
    add_reference :seguros, :seguro, index: true, foreign_key: true
  end
end
