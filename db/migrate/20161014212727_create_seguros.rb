class CreateSeguros < ActiveRecord::Migration
  def change
    create_table :seguros do |t|
      t.references :supplier
      t.references :user
      t.string :numero_poliza, limit: 255
      t.string :numero_contrato, limit: 255
      t.string :factura_numero,  limit: 255
      t.string :factura_autorizacion, limit: 255
      t.date :factura_fecha
      t.float :factura_monto , limit: 53
      t.datetime :fecha_inicio_vigencia
      t.datetime :fecha_fin_vigencia
      t.boolean :baja_logica,  default: false
      t.timestamps null: false
    end
  end
end
