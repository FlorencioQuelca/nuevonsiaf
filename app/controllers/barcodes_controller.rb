class BarcodesController < ApplicationController
  load_and_authorize_resource class: false

  def index
    authorize! :index, :barcode
    @gestiones = Ingreso.obtiene_gestiones_desc
    respond_to do |format|
      format.html
      format.json { render json: {} }
    end
  end

  def obt_cod_barra
      authorize! :obt_cod_barra, :barcode
      params[:searchParam] = "0" unless params[:searchParam].present?
      params[:searchType] = "ACT" unless params[:searchType].present?
      params[:searchGestion] = Date.today.year unless params[:searchGestion].present?
      @activos = Asset.buscar_barcode_to_pdf(params[:searchParam], params[:searchType], params[:searchGestion])
      respond_to do |format|
        format.json { render json: @activos, root: false }
      end
  end

  def pdf
    authorize! :pdf, :barcode
    params[:searchParam] = "0" unless params[:searchParam].present?
    params[:searchType] = "ACT" unless params[:searchType].present?
    params[:searchGestion] = Date.today.year unless params[:searchGestion].present?
    @assets = Asset.buscar_barcode_to_pdf(params[:searchParam], params[:searchType], params[:searchGestion])
    respond_to do |format|
      format.pdf do
        filename = 'código de barras'
        render pdf: "#{filename}".parameterize,
               disposition: 'attachment',
               template: 'barcodes/show.pdf.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: {
                 top: 13,
                 bottom: 0,
                 left: 3,
                 right: 3
               }
      end
    end
  end
  private

    def generate_array_with_codes(desde, hasta)
      Asset.todos.where(code: desde..hasta).order(:code)
    end

end
