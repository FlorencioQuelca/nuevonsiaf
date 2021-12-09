class BuildingsController < ApplicationController
  load_and_authorize_resource
  before_action :set_building, only: [:edit, :update, :show, :change_status]

  # GET /buildings
  # GET /buildings.json
  def index
    format_to('buildings', BuildingsDatatable)
  end

  # GET /buildings/new
  def new
    @building = Building.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  def show
  end

  # GET /buildings/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /buildings
  # POST /buildings.json
  def create
    @building = Building.new(building_params)

    respond_to do |format|
      if @building.save
        format.html { redirect_to buildings_url, notice: t('general.created', model: Building.model_name.human) }
        format.json { render action: 'show', status: :created, location: @building }
      else
        format.html { render action: 'form' }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buildings/1
  # PATCH/PUT /buildings/1.json
  def update
    respond_to do |format|
      if @building.update(building_params)
        format.html { redirect_to buildings_url, notice: t('general.updated', model: Building.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @building.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    authorize! :change_status, :building
    @building.change_status unless @building.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_building
      @building = Building.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def building_params
      params.require(:building).permit(:code, :name, :entity_id, :status)
    end
end
