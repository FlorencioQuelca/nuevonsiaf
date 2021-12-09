class SubarticlesController < ApplicationController
  load_and_authorize_resource
  before_action :set_subarticle, only: [:show, :edit, :update, :destroy, :change_status, :kardex_v2]

  include Fechas

  # GET /subarticles
  def index
    format_to('subarticles', SubarticlesDatatable)
  end

  # GET /subarticles/1
  def show
    desde, hasta = get_fechas(params)
    @transacciones = @subarticle.reporte(desde, hasta)
  end

  # GET /subarticles/new
  def new
    @subarticle = Subarticle.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /subarticles/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /subarticles
  def create
    @subarticle = Subarticle.new(subarticle_params)

    respond_to do |format|
      if @subarticle.save
        format.html { redirect_to subarticles_url, notice: t('general.created', model: Subarticle.model_name.human) }
      else
        Rails.logger.info "**********************#{@subarticle.errors.messages}, #{@subarticle.inspect}"
        format.html { render action: 'form' }
      end
    end
  end

  # PATCH/PUT /subarticles/1
  def update
    respond_to do |format|
      if @subarticle.update(subarticle_params)
        format.html { redirect_to subarticles_url, notice: t('general.updated', model: Subarticle.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @subarticle.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @subarticle.change_status unless @subarticle.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def get_subarticles
    render json: Subarticle.search_subarticle(params[:q]), root: false
  end

  def autocomplete
    subarticles = view_context.search_asset_subarticle(Subarticle, params[:q])
    respond_to do |format|
      format.json { render json: view_context.subarticles_json(subarticles) }
    end
  end

  def first_entry
    entry_subarticle_params.each{ |i,f| EntrySubarticle.create(f)}
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def kardex_v2
    @desde, @hasta = get_fechas(params)
    @datos_kardex = @subarticle.obtiene_kardex_v2(@desde, @hasta)
    respond_to do |format|
      format.html
      format.ods { render ods: SpreadsheetArchitect::to_ods(@subarticle.formato_ods(@datos_kardex)), filename: "kardex_v2" }
      format.pdf do
        filename = 'kardex_v2'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'subarticles/kardex_v2.html.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subarticle
      @subarticle = Subarticle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subarticle_params
      params.require(:subarticle).permit(:description, :code_old, :unit, :status, :amount, :minimum, :material_id)
    end

    def entry_subarticle_params
      params.require(:entry_subarticle).permit!
    end
end
