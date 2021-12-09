class UsersController < ApplicationController
  include ActiveModel::Serialization

  load_and_authorize_resource
  before_action :set_user, only: [:show, :edit, :update, :change_status, :csv, :pdf, :historical, :historico_almacen]

  # GET /users
  # GET /users.json
  def index
    format_to('users', UsersDatatable)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @assets = @user.assets
    @user_json = UserSerializer.new(@user)
    @activos_json = @assets.map { |a| ::AssetSerializer.new(a) }
    @admin = current_user.is_admin? ? '1' : '0'
    respond_to do |format|
      format.html
      format.json { render json: @user, root: false }
    end
  end

  # GET /users/new
  def new
    @user = User.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /users/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /users
  # POST /users.json
  def create
    Thread.current[:fuente_actualizacion] = 'new'
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: t('general.created', model: User.model_name.human) }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'form' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    Thread.current[:fuente_actualizacion] = 'update'
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      if @user.update(user_params)
        list_url = @user.id == current_user.id ? @user : users_url
        format.html { redirect_to list_url, notice: t('general.updated', model: User.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @user.change_status unless @user.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def welcome
    render 'shared/welcome'
  end

  def download
    @assets = @user.assets
    filename = @user.name.parameterize || 'activos'
    respond_to do |format|
      format.html { render nothing: true }
      format.csv do
        send_data @assets.to_csv,
          filename: "#{filename}.csv",
          type: 'text/csv'
      end
      format.pdf do
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  def historical
    proceedings = @user.proceedings
    respond_to do |format|
      format.json { render json: proceedings, each_serializer: ProceedingSerializer, root: false }
    end
  end

  def autocomplete
    render json: User.search_user(params[:q]), root: false
  end

  def historico_almacen
    historial = @user.obtiene_historico_almacenes(params[:q])
    @historial_solicitud = historial.order('fecha_entrega asc, numero_solicitud asc')
    @historial_subarticulo = historial.order('subarticulo_codigo asc, fecha_entrega asc ')
    respond_to do |format|
      format.html
      format.js
      format.csv { send_data User.obtiene_csv_historial(@historial_solicitud), filename: "#{@user.name.parameterize}.csv"  }
      format.pdf do
        filename = @user.name.parameterize || 'historico'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               template: 'users/historico_almacen.html.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /verificar_usuario
  def verificar_usuario
    @user = User.select('id, name, ci, department_id, title, email, username,updated_at').where('role <> ? or role is ?', 'super_admin', nil).order('updated_at desc,name asc, id asc')
  end

  # GET /ver_duplicados
  def ver_duplicados
    @user = User.select('id, name, ci, title, email, username, count(*) as cantidad').group('users.name').union(User.select('id, name, ci, title, email, username, count(*) as cantidad').group('users.ci').where('ci is not null and ci <> ?','')).union(User.select('id, name, ci, title, email, username, count(*) as cantidad').group('users.email').where('email is not null and email <> ?','')).having('cantidad > 1').order('cantidad desc').distinct
  end

  # GET
  def ver_ci_incongruentes
    @documentos_observados = []
  
    User.unscoped.all.each do |usuario|
      if usuario.ci.present?
        cantidad_coincidencias = User.unscoped.where('ci = ? and (name != ? or email != ?)', usuario.ci, usuario.name, usuario.email).count
        if cantidad_coincidencias > 0
          @documentos_observados << usuario.ci
        end
      end
    end
    @documentos_observados = @documentos_observados.uniq
  end

  # GET /verificar_campo
  def verificar_campo
    ci_format = /^[1-9]{1}[0-9]{4,15}(-[a-zA-Z0-9]{2})?$/i
    # email_format = /[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}/i
    email_format = /^[a-zA-Z0-9][a-zA-Z0-9._-]*@[a-zA-Z0-9][a-zA-Z0-9._-]*\\.[a-zA-Z]{2,4}$/i
    @flag_busqueda = false
    @estilos = [{ salida: 0, icon: "glyphicon glyphicon-info-sign", color: "color:blue", size: "font-size:25px", title: "Parametro normal." },
                { salida: 1, icon: "glyphicon glyphicon-info-sign", color: "color:tomato", size: "font-size:25px", title: "Parametro vacio." },
                { salida: 2, icon: "glyphicon glyphicon-info-sign", color: "color:orange", size: "font-size:25px", title: "Parametro nulo" },
                { salida: 3, icon: "glyphicon glyphicon-info-sign", color: "color:red", size: "font-size:25px", title: "Parametro que no coincide con el patron." },
                { salida: 4, icon: "glyphicon glyphicon-info-sign", color: "color:tomato", size: "font-size:25px", title: "Registro observado." }
              ]
    if params[:campo].present?

      fields = { 'id': { condicion: ["= ' '", "is null"], salida: [1,2] },
                  'name': { condicion: ["= ' '", "is null"], salida: [1,2] },
                  'ci': { condicion: ["= ' '", "is null", "REGEXP '#{ci_format}' = 0"], salida: [1,2,3] },
                  'department_id': { condicion: ["= ' '", "is null"], salida: [1,2] },
                  'title': { condicion: ["= ' '", "is null"], salida: [1,2] },
                  'email': { condicion: ["= ' '", "is null", "REGEXP '#{email_format}' = 0"], salida: [1,2,3] },
                  'username': { condicion: ["= ' '", "is null"], salida: [1,2] }
                }
      restricciones = ''
      if params[:campo] == 'all'
        restricciones += "when id = ' ' or id is null then 4 "
        restricciones += "when name = ' ' or name is null then 4 "
        restricciones += "when ci = ' ' or ci is null or ci REGEXP '#{ci_format}' = 0 then 4 "
        restricciones += "when department_id = ' ' or department_id is null then 4 "
        restricciones += "when title = ' ' or title is null then 4 "
        restricciones += "when email = ' ' or email is null then 4 "
        # restricciones += "when username = ' ' or username is null then 4 "
      else
        fields[:"#{params[:campo]}"][:condicion].each_with_index do |valor, index|
          restricciones += "when #{params[:campo]} #{valor} then #{fields[:"#{params[:campo]}"][:salida][index]} "
        end
      end
    else
      @flag_busqueda = true
    end

    if !@flag_busqueda
      @user = User.select("id, name, ci, department_id, title, email, username, updated_at, case #{restricciones} else 0 end as flag").where('role <> ? or role is ?', 'super_admin', nil).order('flag desc, updated_at desc, name asc, id asc')
    else
      @user = User.where('name like ? and (role <> ? or role is ?)', "%#{params[:busqueda][:nombre]}%", 'super_admin', nil).select('id, name, ci, department_id, title, email, username, updated_at, 0 as flag').order('name asc, id asc')
    end
  end

  # POST /agrupacion_usuario
  def agrupacion_usuario
    @user_new = User.new
    users_selected = []
    user_count = User.count
    user_count.times do |i|
      if params[:"select_user_#{i}"].present?
        users_selected << params[:"select_user_#{i}"]
      end
    end
    @usr_ids = users_selected
    @user = User.joins(' as u left outer join departments as d on u.department_id = d.id')
                .select('u.id, u.name, u.ci, u.department_id, u.title, u.email, d.name as dpto')
                .order('u.id').where('u.id in (?)', users_selected)
  end

  # POST /guardar_agrupacion
  def guardar_agrupacion
    begin
      Thread.current[:fuente_actualizacion] = 'agrupacion'
      respond_to do |format|
        usuarios_ids = params[:users_update].split(',')
        usuarios_data = []

        ajustar_email = false
        email_existentes = User.pluck(:email)
        usuarios_ids.each do |usuario_id|
          email_unico = user_params[:email].strip
          loop do
            email_unico = user_params[:email].strip.gsub('@', "#{(SecureRandom.random_number * (10**3)).round.to_s}@")
            break unless email_existentes.include?(email_unico)
          end
          email_existentes << email_unico

          usuarios_data << {name: user_params[:name].strip, ci: user_params[:ci].strip, title: user_params[:title].strip, department_id: user_params[:department_id].strip, email: email_unico}
        end

        # # usr = User.where('id in (?)', params[:users_update].split(','))
        # usr = User.update(usuarios_ids, usuarios_data)
        # if usr = usuarios_ids.length
        #   format.html { redirect_to verificar_usuario_users_path, notice: 'Usuarios agrupados correctamente.' }
        # elsif usr > 0
        #   format.html { redirect_to verificar_usuario_users_path, alert: 'Usuarios agrupados parcialmente, algunos registros no han podido actualizarse correctamente.' }
        # else
        #   format.html { redirect_to verificar_usuario_users_path, alert: 'No se ha podido actualizar ningun registro correctamente.' }
        # end
        user = User.update(usuarios_ids, usuarios_data)
        @user_new = user.last
        unless @user_new.errors.any?
          user_aux = User.where('id in (?)', usuarios_ids).update_all(email: user_params[:email].strip)
          if user_aux == usuarios_ids.length
            format.html { redirect_to verificar_usuario_users_path, notice: 'Registros actualizados satisfactoriamente' }
            format.json { head :no_content }
          else
            format.html { redirect_to verificar_usuario_users_path, alert: 'Usuarios actualizados parcialmente, algunos registros no han podido actualizarse correctamente. Intente nuevamente' }
          end
        else
          @usr_ids = usuarios_ids
          @user = User.joins(' as u left outer join departments as d on u.department_id = d.id')
                  .select('u.id, u.name, u.ci, u.department_id, u.title, u.email, d.name as dpto')
                  .order('u.id').where('u.id in (?)', usuarios_ids)
          format.html { render action: 'agrupacion_usuario' }
          format.json { render json: @user_new.errors, status: :unprocessable_entity }
        end
      end
    rescue StandardError => e
      Rails.logger.info e.message
      respond_to do |format|
        format.html { redirect_to verificar_usuario_users_path, alert: 'Error inesperado al intentar guardar los datos: ' + e.message }
      end
    end
  end

  # POST /eliminar_usuario
  def eliminar_usuario
    respond_to do |format|
      format.html { redirect_to verificar_usuario_users_path, notice: 'Usuario Eliminado? '}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      if current_user.is_super_admin?
        params.require(:user).permit(:name, :title, :ci, :email, :phone, :mobile, :department_id, :role, :password, :password_confirmation)
      else
        params.require(:user).permit(:name, :title, :ci, :email, :phone, :mobile, :department_id, :password, :password_confirmation)
      end
    end
end
