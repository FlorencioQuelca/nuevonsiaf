class AddNitAndTelefonoAndContactoToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :nit, :string
    add_column :suppliers, :telefono, :string
    add_column :suppliers, :contacto, :string
  end
end
