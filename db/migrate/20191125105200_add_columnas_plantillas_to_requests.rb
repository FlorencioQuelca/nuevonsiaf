class AddColumnasPlantillasToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :documento_id, :integer, unique: true, index: true
    add_column :requests, :json_usuarios, :text
    add_column :requests, :cite_sms, :string
    add_column :requests, :cite_ems, :string

    Request.unscoped.all.includes(:user).each do |request|
      user = request.user
      unidad_solicitante = user.present? ? user.department : nil
      admin = request.admin
      unidad_responsable = admin.present? ? admin.department : nil
      request.json_usuarios = {solicitado_por: {id: ApplicationController.helpers.validar_valor_registro(user, 'id'), nombre: ApplicationController.helpers.validar_valor_registro(user, 'name'), numero_documento: ApplicationController.helpers.validar_valor_registro(user, 'ci'), cargo: ApplicationController.helpers.validar_valor_registro(user, 'title'), unidad: ApplicationController.helpers.validar_valor_registro(unidad_solicitante, 'name'), email: ApplicationController.helpers.validar_valor_registro(user,'email')}, entregado_por: {id: ApplicationController.helpers.validar_valor_registro(admin, 'id'), nombre: ApplicationController.helpers.validar_valor_registro(admin, 'name'), numero_documento: ApplicationController.helpers.validar_valor_registro(admin, 'ci'), cargo: ApplicationController.helpers.validar_valor_registro(admin, 'title'), unidad: ApplicationController.helpers.validar_valor_registro(unidad_responsable, 'name'), email: ApplicationController.helpers.validar_valor_registro(admin, 'email')}}.to_json
      request.save
    end
  end
end
