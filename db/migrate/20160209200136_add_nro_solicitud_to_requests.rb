class AddNroSolicitudToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :nro_solicitud, :integer, default: 0
  end
end
