namespace :db do

  ###################################################
  # LIMPIEZA DE USUARIOS DE ACTIVOS Y ALMACENES
  ###################################################
  desc "Limpieza de usuarios del sistema de activos"
  task :limpiar_usuarios => :environment do
    # puts "Limpieza de usuarios del sistema de ACTIVOS Y ALMACENES\n"
    # puts "Estas seguro? (s/n) => "
    # input = STDIN.gets.strip.downcase
    # unless input == 's'
    #   next
    # end

    # ActiveRecord::Base.transaction do
    #   usuarios_a_eliminar = []

    #   ###################################################
    #   # ACTIVOS
    #   ###################################################
    #   puts "**** ACTIVOS *****"
    #   puts "Limpiando Gestiones..."
    #   Gestion.unscoped.all.includes(:user).each do |gestion|
    #     user = gestion.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         gestion.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   puts "Limpiando Bajas..."
    #   Baja.unscoped.all.includes(:user).each do |baja|
    #     user = baja.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         baja.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   puts "Limpiando ingresos..."
    #   Ingreso.unscoped.all.includes(:user).each do |ingreso|
    #     user = ingreso.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         ingreso.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   puts "Limpiando Assests(Activos)..."
    #   Asset.unscoped.all.includes(:user).each do |activo|
    #     user = activo.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         activo.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   puts "Limpiando Seguros..."
    #   Seguro.unscoped.all.includes(:user).each do |seguro|
    #     user = seguro.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         seguro.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end


    #   puts "Limpiando Proceedings(actas)..."
    #   # actas
    #   Proceeding.unscoped.all.includes(:user).each do |proced|
    #     user = proced.user
    #     admin = proced.admin
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         proced.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end

    #     if admin.present? && admin.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(admin.ci)
    #       if usuario_intacto != admin.id
    #         proced.update_attribute(:admin_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   ###################################################
    #   # ALMACENES
    #   ###################################################
    #   puts "**** ALMACENES *****"
    #   puts "Limpiando NoteEntries..."
    #   NoteEntry.unscoped.all.includes(:user).each do |note|
    #     user = note.user
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         note.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   puts "Limpiando Requests..."
    #   Request.unscoped.all.includes(:user).each do |request|
    #     user = request.user
    #     admin = request.admin
    #     if user.present? && user.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(user.ci)
    #       if usuario_intacto != user.id
    #         request.update_attribute(:user_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end

    #     if admin.present? && admin.ci.present?
    #       usuario_intacto, usuarios_duplicados = obtener_usuarios(admin.ci)
    #       if usuario_intacto != admin.id
    #         request.update_attribute(:admin_id, usuario_intacto)
    #       end
    #       usuarios_a_eliminar.concat(usuarios_duplicados)
    #     end
    #   end

    #   ###################################################
    #   # ELiminar usuarios duplicados
    #   ###################################################
    #   puts "**** DUPLICIDAD *****"
    #   puts "Eliminando usuarios duplicados..."
    #   usuarios_unicos_a_eliminar = usuarios_a_eliminar.uniq
    #   User.unscoped.where(id: usuarios_unicos_a_eliminar).destroy_all
    #   puts "Cantidad de usuarios duplicados eliminados::: #{usuarios_unicos_a_eliminar.count}"
    #   puts "**** USERNAME *****"
    #   puts "Sincronizando nombres de usuario..."
    #   User.unscoped.all.each do |user|
    #     user.username = user.ci
    #     user.save
    #   end
    # end
  end

  def obtener_usuarios(usuario_ci)
    usuarios = User.unscoped.where(ci: usuario_ci).order(id: :asc).ids
    # [usuarios.last, usuarios.first(usuarios.count() -1)]
    [usuarios.first, usuarios[1,(usuarios.count-1)]]

  end

end
