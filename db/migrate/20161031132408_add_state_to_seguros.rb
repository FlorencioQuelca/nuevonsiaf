class AddStateToSeguros < ActiveRecord::Migration
  def change
    add_column :seguros, :state, :string
  end
end
