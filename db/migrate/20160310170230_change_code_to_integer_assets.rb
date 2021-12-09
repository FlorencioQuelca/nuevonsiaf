class ChangeCodeToIntegerAssets < ActiveRecord::Migration
  def up
    # Adición de columna temporal para guardar el código actual
    add_column :assets, :codigo_antiguo, :string
    Asset.update_all('codigo_antiguo=code, code=null')

    change_column :assets, :code, :integer
  end

  def down
    change_column :assets, :code, :string, limit: 50

    # Reversión de la columna temporal al campo 'code'
    Asset.update_all('code = codigo_antiguo')
    remove_column :assets, :codigo_antiguo
  end
end
