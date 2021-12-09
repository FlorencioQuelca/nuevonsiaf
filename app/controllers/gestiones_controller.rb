class GestionesController < ApplicationController
  load_and_authorize_resource
  before_action :set_gestion, only: [:show, :edit, :update, :destroy, :cerrar]

  # GET /gestiones
  # GET /gestiones.json
  def index
    format_to('gestiones', GestionesDatatable)
  end

  # GET /gestiones/1
  # GET /gestiones/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gestion }
    end
  end

  # GET /gestiones/new
  def new
    @gestion = Gestion.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /gestiones/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /gestiones
  # POST /gestiones.json
  def create
    @gestion = Gestion.new(gestion_params)

    respond_to do |format|
      if @gestion.save
        format.html { redirect_to gestiones_url, notice: t('general.created', model: Gestion.model_name.human) }
        format.json { render json: @gestion, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @gestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gestiones/1
  # PATCH/PUT /gestiones/1.json
  def update
    respond_to do |format|
      if @gestion.update(gestion_params)
        format.html { redirect_to gestiones_url, notice: t('general.updated', model: Gestion.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @gestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gestiones/1
  # DELETE /gestiones/1.json
  def destroy
    @gestion.destroy
    respond_to do |format|
      format.html { redirect_to gestiones_url }
      format.json { head :no_content }
    end
  end

  def cerrar
    respond_to do |format|
      if @gestion.gestion_actual?
        Gestion.cerrar_gestion_actual(current_user)
        format.json { head :no_content }
      else
        error = { mensaje: 'No es la gestión actual vigente' }
        format.json { render json: error, status: :unprocessable_entity}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gestion
      @gestion = Gestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gestion_params
      params.require(:gestion).permit(:anio)
    end
end
