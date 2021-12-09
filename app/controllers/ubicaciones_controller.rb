class UbicacionesController < ApplicationController
  before_action :set_ubicacion, only: [:show, :edit, :update, :destroy]

  # GET /ubicaciones
  # GET /ubicaciones.json
  def index
    format_to('ubicaciones', UbicacionesDatatable)
  end

  # GET /ubicaciones/1
  # GET /ubicaciones/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ubicacion }
    end
  end

  # GET /ubicaciones/new
  def new
    @ubicacion = Ubicacion.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /ubicaciones/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /ubicaciones
  # POST /ubicaciones.json
  def create
    @ubicacion = Ubicacion.new(ubicacion_params)

    respond_to do |format|
      if @ubicacion.save
        format.html { redirect_to ubicaciones_url, notice: t('general.created', model: Ubicacion.model_name.human) }
        format.json { render json: @ubicacion, status: :created }
      else
        format.html { render action: 'form' }
        format.json { render json: @ubicacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ubicaciones/1
  # PATCH/PUT /ubicaciones/1.json
  def update
    respond_to do |format|
      if @ubicacion.update(ubicacion_params)
        format.html { redirect_to ubicaciones_url, notice: t('general.updated', model: Ubicacion.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @ubicacion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ubicaciones/1
  # DELETE /ubicaciones/1.json
  def destroy
    @ubicacion.destroy
    respond_to do |format|
      format.html { redirect_to ubicaciones_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ubicacion
      @ubicacion = Ubicacion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ubicacion_params
      params.require(:ubicacion).permit(:abreviacion, :descripcion)
    end
end
