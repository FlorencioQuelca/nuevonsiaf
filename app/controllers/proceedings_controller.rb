class ProceedingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_proceeding, only: [:show, :update]

  # GET /proceedings
  def index
    format_to('proceedings', ProceedingsDatatable)
  end

  # GET /proceedings/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        filename = @proceeding.user_name.parameterize || 'acta'
        render pdf: "#{filename}",
               disposition: 'attachment',
               template: 'proceedings/show.html.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # POST /proceedings
  def create
    @error_guardar_acta = false
    mostrar_error_interno = false
    begin

      if Rails.application.secrets.interoperabilidad_plantillas.present?
        mostrar_error_interno = true
        raise "No puede realizar este procedimiento cuando la interoperabilidad esta activa."
      end

      # verificar que ningun activo este dado de baja
      cantidad_activos_con_baja = Asset.conbaja.where(id: proceeding_params[:asset_ids]).count
      if cantidad_activos_con_baja > 0
        mostrar_error_interno = true
        raise "Uno o más activos estan dados de baja, verifique la disponibilidad de los activos."
      end

      if (proceeding_params[:proceeding_type] == "E") # asignacion
        # Validar que los activos no esten asignados a nadie
        cantidad_activos_validos = Asset.where(id: proceeding_params[:asset_ids], user_id: nil).count

        unless (proceeding_params[:asset_ids].count == cantidad_activos_validos)
          mostrar_error_interno = true
          raise "Uno o más activos ya estan asignados, verifique que todos los activos esten disponibles."
        end
      end

      if (proceeding_params[:proceeding_type] == "D") # asignacion
        # Validar que los activos esten asignados
        cantidad_activos_validos = Asset.assigned.where(id: proceeding_params[:asset_ids]).count

        unless (proceeding_params[:asset_ids].count == cantidad_activos_validos)
          mostrar_error_interno = true
          raise "Uno o más activos no estan asignados, verifique que todos los activos esten asignados."
        end
      end

      @proceeding = Proceeding.new(proceeding_params)
      @proceeding.admin_id = current_user.id
      
      # usuario solicitante
      usuarios = {}
      usuario_solicitante = User.find(proceeding_params[:user_id])
      if usuario_solicitante.present?
        usuarios = {solicitado_por: {id: usuario_solicitante.id, numero_documento: ApplicationController.helpers.validar_valor(usuario_solicitante.ci), cargo: ApplicationController.helpers.validar_valor(usuario_solicitante.title), unidad: ApplicationController.helpers.validar_valor(usuario_solicitante.department_name), email: ApplicationController.helpers.validar_valor(usuario_solicitante.email)}, realizado_por: {id: current_user.id, numero_documento: ApplicationController.helpers.validar_valor(current_user.ci), cargo: ApplicationController.helpers.validar_valor(current_user.title), unidad: ApplicationController.helpers.validar_valor(current_user.department_name), email: ApplicationController.helpers.validar_valor(current_user.email)}}
      end
      @proceeding.usuario_info = usuarios.to_json

      respond_to do |format|
        if @proceeding.asset_ids.present? && @proceeding.save
          format.js
        else
          mostrar_error_interno = true
          raise 'Ocurrio un error al guardar el acta, contactese con el administrador del sistema.'
        end
      end
      
    rescue StandardError => e
      Rails.logger.info e.message
      @error_guardar_acta = true
      @error_msg = mostrar_error_interno ? e.message : 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
      respond_to do |format|
        format.js
      end
    end
  end

  # PATCH/PUT /proceedings/1
  def update
    @proceeding.update(proceeding_params)
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proceeding
      @proceeding = Proceeding.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def proceeding_params
      params.require(:proceeding).permit(:user_id, { asset_ids: [] }, :proceeding_type, :fecha, :observaciones)
    end
end
