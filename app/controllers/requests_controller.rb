class RequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_request, only: [:show]
  before_action :verificar_interoperabilidad, only: [:new, :create]

  # GET /requests
  def index
    format_to('requests', RequestsDatatable)
  end

  # GET /requests/1
  def show
    @status_pdf = params[:status]
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@request.user_name.parameterize || 'materiales'}",
               disposition: 'attachment',
               template: 'requests/show.html.haml',
               layout: 'pdf.html',
               # show_as_html: params.key?('debug'),
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /requests/new
  def new
  end

  # POST /requests
  def create
    @request = Request.new(request_params)
    @request.admin_id = current_user.id

    # Guardar historico de usuarios(En caso de cambios de cargo y unidad)
    @request.json_usuarios = {solicitado_por: User.obtener_datos(@request.user_id)}.to_json

    @request.save
    Subarticle.register_log('request')
  end

  # PATCH/PUT /requests/1
  def update
    @request.admin_id = current_user.id
    
    if @request.status == 'initiation'
      json_usuarios = JSON.parse(@request.json_usuarios || {}.to_json)
      json_usuarios["entregado_por"] = User.obtener_datos(current_user.id)
      @request.json_usuarios = json_usuarios.to_json

      @request.entregar_subarticulos(request_params)
    else
      @request.update(request_params)
    end
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Actualizado correctamente' }
      format.json { render nothing: true }
      format.js
    end
  end

  def obtiene_nro_solicitud
    resultado = Hash.new
    if params[:d].present?
      fecha = params[:d].to_date
      if params[:n].present?
        solicitud = Request.find(params[:n])
        unless solicitud.nro_solicitud.present?
          resultado = Request.obtiene_siguiente_numero_solicitud(fecha)
        end
      else
        resultado = Request.obtiene_siguiente_numero_solicitud(fecha)
      end
      if resultado[:tipo_respuesta] == 'confirmacion'
        resultado[:titulo] = 'Confirmación de Solicitud'
      elsif resultado[:tipo_respuesta] == 'alerta'
        resultado[:titulo] = 'Alerta de Solicitud'
      end
    end
    render json: resultado, root: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    def verificar_interoperabilidad
      if Rails.application.secrets.interoperabilidad_plantillas.present?
        redirect_to requests_url, alert: 'Acceso denegado'
      end
    end

    # Only allow a trusted parameter "white list" through.
    def request_params
      params.require(:request).permit(:user_id, :status, :delivery_date, :created_at, :nro_solicitud, :observacion, { subarticle_requests_attributes: [ :id, :subarticle_id, :amount, :amount_delivered ] } )
    end


  def search_date
    case params[:rank]
    when "today"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_day
      params[:q]["request_created_at_lteq"] = Time.now.end_of_day
    when "week"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_week
      params[:q]["request_created_at_lteq"] = Time.now.end_of_week
    when "month"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_month
      params[:q]["request_created_at_lteq"] = Time.now.end_of_month
    when "year"
      params[:q]["request_created_at_gteq"] = Time.now.beginning_of_year
      params[:q]["request_created_at_lteq"] = Time.now.end_of_year
    end
  end
end
