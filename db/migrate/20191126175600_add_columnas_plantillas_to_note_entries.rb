class AddColumnasPlantillasToNoteEntries < ActiveRecord::Migration
  def change
    add_column :note_entries, :documento_id, :integer, unique: true, index: true
    add_column :note_entries, :json_usuarios, :text

    NoteEntry.unscoped.all.includes(:user).each do |note|
      user = note.user
      unidad = user.present? ? user.department : nil
      note.json_usuarios = {id: ApplicationController.helpers.validar_valor_registro(user,'id'), nombre: ApplicationController.helpers.validar_valor_registro(user, 'name'), numero_documento: ApplicationController.helpers.validar_valor_registro(user, 'ci'), cargo: ApplicationController.helpers.validar_valor_registro(user, 'title'), unidad: ApplicationController.helpers.validar_valor_registro(unidad, 'name'), email: ApplicationController.helpers.validar_valor_registro(user, 'email')}.to_json
      note.save
    end
  end
end
