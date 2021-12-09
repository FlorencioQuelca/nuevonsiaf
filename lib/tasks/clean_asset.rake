namespace :db do

  ###################################################
  # DESASIGNAR ACTIVOS DE RESPONSABLE DE ACTIVOS
  ###################################################
  desc "Desasignar activos de responsable de activos"
  task :desasignar_activos => :environment do
    # puts "Se ha que desasignar todos los activos de Claudia Segurondo\n"
    # puts "Estas seguro? (s/n) => "
    # input = STDIN.gets.strip.downcase
    # unless input == 's'
    #   next
    # end

    # administrador_activos = User.find_by(ci: 4914412)
    # activos_asignados = Asset.where(user_id: administrador_activos.id).ids

    # usuario_info = {solicitado_por: {id: administrador_activos.id, numero_documento: ApplicationController.helpers.validar_valor(administrador_activos.ci), cargo: ApplicationController.helpers.validar_valor(administrador_activos.title), unidad: ApplicationController.helpers.validar_valor(administrador_activos.department_name), email: ApplicationController.helpers.validar_valor(administrador_activos.email)}, realizado_por: {id: administrador_activos.id, numero_documento: ApplicationController.helpers.validar_valor(administrador_activos.ci), cargo: ApplicationController.helpers.validar_valor(administrador_activos.title), unidad: ApplicationController.helpers.validar_valor(administrador_activos.department_name), email: ApplicationController.helpers.validar_valor(administrador_activos.email)}}

    # datos_acta = {
    #   user_id: administrador_activos.id,
    #   admin_id: administrador_activos.id,
    #   asset_ids: activos_asignados,
    #   proceeding_type: 'D',
    #   fecha: Date.today,
    #   observaciones: 'Interoperabilidad con plantillas',
    #   usuario_info: usuario_info.to_json
    # }

    # proceeding = Proceeding.new(datos_acta)

    # if proceeding.asset_ids.present? && proceeding.save
    #   puts "#{activos_asignados.length} activos desasignados satisfactoriamente."
    # else
    #   puts 'Ocurrio un error en la desasignación de activos'
    # end

    puts "Se ha actualizar la cantidad de activos por usuario\n"
    puts "Estas seguro? (s/n) => "
    input = STDIN.gets.strip.downcase
    unless input == 's'
      next
    end

    User.unscoped.where('role != ?', 'super_admin').each do |usuario|
      User.reset_counters(usuario.id, :assets)
    end
    puts 'Actualización de cantidad de activos por usuario, completado satisfactoriamente.'

  end

end
