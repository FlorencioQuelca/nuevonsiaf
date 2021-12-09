class AuxiliariesController < ApplicationController
  load_and_authorize_resource
  before_action :set_auxiliary, only: [:show, :edit, :update, :change_status, :activos]

  # GET /auxiliaries
  # GET /auxiliaries.json
  def index
    format_to('auxiliaries', AuxiliariesDatatable)
  end

  # GET /auxiliaries/1
  # GET /auxiliaries/1.json
  def show
    @data = {
      id: @auxiliary.id,
      urls: {
        show: api_auxiliare_path(@auxiliary),
        edit: edit_auxiliary_path(@auxiliary),
        list: auxiliaries_path,
        pdf: activos_auxiliary_path(@auxiliary, format: :pdf),
        account_url: account_path(@auxiliary.account_id)
      }
    }
  end

  # GET /auxiliaries/new
  def new
    @auxiliary = Auxiliary.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /auxiliaries/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /auxiliaries
  # POST /auxiliaries.json
  def create
    @auxiliary = Auxiliary.new(auxiliary_params)

    respond_to do |format|
      if @auxiliary.save
        format.html { redirect_to auxiliaries_url, notice: t('general.created', model: Auxiliary.model_name.human) }
        format.json { render action: 'show', status: :created, location: @auxiliary }
      else
        format.html { render action: 'form' }
        format.json { render json: @auxiliary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auxiliaries/1
  # PATCH/PUT /auxiliaries/1.json
  def update
    respond_to do |format|
      if @auxiliary.update(auxiliary_params)
        format.html { redirect_to auxiliaries_url, notice: t('general.updated', model: Auxiliary.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @auxiliary.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @auxiliary.change_status unless @auxiliary.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def activos
    @activos = @auxiliary.assets
    respond_to do |format|
      format.pdf do
        filename = 'activos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'auxiliaries/activos.pdf.haml',
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
    def set_auxiliary
      @auxiliary = Auxiliary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def auxiliary_params
      params.require(:auxiliary).permit(:code, :name, :account_id, :status)
    end
end
