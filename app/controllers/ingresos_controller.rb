class IngresosController < ApplicationController
  load_and_authorize_resource
  before_action :set_ingreso, only: [:show, :edit, :update, :destroy]
  before_action :verificar_interoperabilidad, only: [:new, :edit, :create, :update]

  # GET /ingresos
  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('ingresos', IngresosDatatable)
    end
  end

  # GET /ingresos/1
  def show
    @activos = @ingreso.assets.order(:code)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Ingreso #{@ingreso.nota_entrega_fecha}".parameterize,
               disposition: 'attachment',
               template: 'ingresos/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               # show_as_html: params[:debug].present?,
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /ingresos/new
  def new
    @ingreso = Ingreso.new
  end

  # GET /ingresos/1/edit
  def edit
    render 'new'
  end

  # POST /ingresos
  def create
    @ingreso = current_user.ingresos.new(ingreso_params)
    respond_to do |format|
      if @ingreso.save
        format.html { redirect_to @ingreso, notice: 'Ingreso creado exitosamente' }
        format.json { render json: @ingreso, status: :created }
      else
        format.html { render :new }
        format.json { render json: @ingreso.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ingresos/1
  def update
    respond_to do |format|
      if @ingreso.update(ingreso_params)
        format.html { redirect_to @ingreso, notice: t('general.updated', model: Ingreso.model_name.human) }
        format.js
      else
        format.html { render action: 'new' }
      end
    end
  end

  def obt_cod_ingreso
    resultado = Hash.new
    if params[:d].present?
      fecha = params[:d].to_date
      if params[:n].present?
        nota_ingreso = Ingreso.find(params[:n])
        unless nota_ingreso.numero.present?
          resultado = Ingreso.obtiene_siguiente_numero_ingreso(fecha)
        end
      else
        resultado = Ingreso.obtiene_siguiente_numero_ingreso(fecha)
      end
      if resultado[:tipo_respuesta] == 'confirmacion'
        resultado[:titulo] = "Confirmación de Ingreso"
      elsif resultado[:tipo_respuesta] == 'alerta'
        resultado[:titulo] = "Alerta de Ingreso"
      end
    end
    render json: resultado, root: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ingreso
      @ingreso = Ingreso.find(params[:id])
    end

    def verificar_interoperabilidad
      if Rails.application.secrets.interoperabilidad_plantillas.present?
        redirect_to ingresos_url, alert: 'Acceso denegado'
      end
    end

    # Only allow a trusted parameter "white list" through.
    def ingreso_params
      params.require(:ingreso).permit(:numero, :supplier_id, :factura_numero, :factura_autorizacion, :factura_fecha, :nota_entrega_numero, :nota_entrega_fecha, :c31_numero, :c31_fecha, :total, :tipo_ingreso, :entidad_donante, :observacion, asset_ids: [])
    end
end
