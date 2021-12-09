class BajasController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:barcode].present?
      barcode = params[:barcode]
      activos = Asset.where('baja_id is null')
                     .buscar_por_barcode(barcode)
      render json: activos, root: false
    else
      format_to('bajas', BajasDatatable)
    end
  end

  def new
    @motivos = Baja::MOTIVOS
    @baja = Baja.new
  end

  def show
    @baja = Baja.find(params[:id])
    @activos = @baja.assets
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Baja #{@baja.fecha}".parameterize,
               disposition: 'attachment',
               template: 'bajas/show.html.haml',
               layout: 'pdf.html',
               page_size: 'Letter',
               # show_as_html: params[:debug].present?,
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  def create
    @baja = current_user.bajas.new(baja_params)
    respond_to do |format|
      if @baja.save
        format.html { redirect_to @baja, notice: 'Ingreso creado exitosamente' }
        format.json { render json: @baja, status: :created }
      else
        format.html { render :new }
        format.json { render json: @baja.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def baja_params
    params.require(:baja).permit(:documento, :fecha_documento, :fecha, :motivo, :observacion, asset_ids: [])
  end
end
