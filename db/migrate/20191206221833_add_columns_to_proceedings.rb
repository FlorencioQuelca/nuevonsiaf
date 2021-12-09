class AddColumnsToProceedings < ActiveRecord::Migration
  def change
    add_column :proceedings, :observaciones, :string, default: 'Ninguno'
    add_column :proceedings, :usuario_info, :text
    add_column :proceedings, :plantillas_info, :string

    Proceeding.unscoped.all.includes(:user).each do |acta|
      user = acta.user
      unidad_solicitante = user.present? ? user.department : nil
      admin = acta.admin
      unidad_responsable = admin.present? ? admin.department : nil
      acta.usuario_info = {solicitado_por: {id: ApplicationController.helpers.validar_valor_registro(user, 'id'), numero_documento: ApplicationController.helpers.validar_valor_registro(user, 'ci'), cargo: ApplicationController.helpers.validar_valor_registro(user, 'title'), unidad: ApplicationController.helpers.validar_valor_registro(unidad_solicitante, 'name'), email: ApplicationController.helpers.validar_valor_registro(user,'email')}, realizado_por: {id: ApplicationController.helpers.validar_valor_registro(admin, 'id'), numero_documento: ApplicationController.helpers.validar_valor_registro(admin, 'ci'), cargo: ApplicationController.helpers.validar_valor_registro(admin, 'title'), unidad: ApplicationController.helpers.validar_valor_registro(unidad_responsable, 'name'), email: ApplicationController.helpers.validar_valor_registro(admin, 'email')}}.to_json
      acta.save
    end
  end
end
