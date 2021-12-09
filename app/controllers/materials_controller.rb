class MaterialsController < ApplicationController
  load_and_authorize_resource
  before_action :set_material, only: [:show, :edit, :update, :change_status]
  skip_before_action :verify_authenticity_token

  include Fechas

  # GET /materials
  def index
    format_to('materials', MaterialsDatatable)
  end

  # GET /materials/1
  def show
  end

  # GET /materials/new
  def new
    @material = Material.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /materials/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /materials
  def create
    @material = Material.new(material_params)

    respond_to do |format|
      if @material.save
        format.html { redirect_to materials_url, notice: t('general.created', model: Material.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  # PATCH/PUT /materials/1
  def update
    respond_to do |format|
      if @material.update(material_params)
        format.html { redirect_to materials_url, notice: t('general.updated', model: Material.model_name.human) }
      else
        format.html { render action: 'form' }
      end
    end
  end

  def change_status
    @material.change_status unless @material.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def reports
    authorize! :reports, Material
    @desde, @hasta = get_fechas(params)
  end

  def fisico_valorado
    @materiales = JSON.parse(params[:listaMateriales])["materiales"]
    @subtotales = JSON.parse(params[:subtotales])
    @total = params["total"]
    @mostrar_reg_cero = (params[:cero].present? ? false : true)
    @subarticulos = params[:listaSubarticulos].map{|s| JSON.parse(s)['subarticulos'] }.flatten
    @desde, @hasta = get_fechas(params)
    filename = 'inventario-fisico-valorado'
    respond_to do |format|
      format.pdf do
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'materials/fisico_valorado.html.haml',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material
      @material = Material.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def material_params
      params.require(:material).permit(:code, :description, :status)
    end
end
