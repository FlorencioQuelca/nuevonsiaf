class AddTipoToSeguro < ActiveRecord::Migration
  def change
    add_column :seguros, :tipo, :string
  end
end
