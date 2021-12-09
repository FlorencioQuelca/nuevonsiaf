class AssetsController < ApplicationController
  load_and_authorize_resource
  before_action :set_asset, only: [:show, :edit, :update, :historical, :depreciacion]

  # GET /assets
  # GET /assets.json
  def index
    @activos_sin_seguro = Asset.sin_seguro_vigente.size
    @seguros = Seguro.vigentes
    format_to('assets', AssetsDatatable)
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
  end

  # GET /assets/new
  def new
    if params[:activo_id].present?
      @asset = Asset.find(params[:activo_id]).dup rescue Asset.new
    else
      @asset = Asset.new
    end
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /assets/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = Asset.new(asset_params)

    respond_to do |format|
      if @asset.save
        format.html { redirect_to assets_url, notice: t('general.created', model: Asset.model_name.human) }
        format.json { render action: 'show', status: :created, location: @asset }
      else
        format.html { render action: 'form' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  def update
    respond_to do |format|
      if @asset.update(asset_params)
        format.html { redirect_to assets_url, notice: t('general.updated', model: Asset.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  def users
    department = params[:department].present? ? params[:department] : (params[:q].present? ? params[:q][:request_user_department_id_eq] : '')
    respond_to do |format|
      format.json { render json: User.actives.order(:name).search_by(department), root: false }
    end
  end

  def departments
    building = params[:building].present? ? params[:building] : params[:q][:request_user_department_building_id_eq]
    respond_to do |format|
      format.json { render json: Department.actives.order(:name).search_by(building), root: false }
    end
  end

  # Obtener activos para devoluciones
  def search
    estado = 0 # Activo inexistente
    mensaje = "El activo con código <b>#{params[:code]}</b> no existe"
    asset = Asset.find_by_barcode params[:code]

    if asset.present?
      if asset.baja_id.nil?
        unless asset.user_id.nil?
          estado = 1 # Activo disponible para devolucion
          mensaje = 'Activo disponible para devolución'
        else
          estado = 2 # Activo no asignado
          mensaje = "El activo con código <b>#{asset.code}</b> no esta asignado"
          asset = nil
        end
      else
        estado = 3 # Activo con baja
        mensaje = "El activo con código <b>#{asset.code}</b> esta dado de baja"
        asset = nil
      end
    end

    respond_to do |format|
      format.json { render json: {estado: estado, mensaje: mensaje, activo: AdminAssetSerializer.new(asset)} }
    end
  end

  # Obtener activos para la asignación
  def admin_assets
    estado = 0 # Activo inexistente
    mensaje = "El activo con código <b>#{params[:code]}</b> no existe"
    asset =  Asset.find_by_barcode params[:code]

    if asset.present?
      if asset.baja_id.nil?
        if asset.user_id.nil?
          estado = 1 # Activo disponible
          mensaje = 'Activo disponible'
        else
          estado = 2 # Activo ya asignado
          mensaje = "El Activo con código <b>#{asset.code}</b> ya está asignado al funcionario <b>#{asset.user.name}</b>"
          asset = nil
        end
      else
        estado = 3 # Activo dado de baja
        mensaje = "El Activo con código <b>#{asset.code}</b> esta dado de baja"
        asset = nil
      end
    end
    
    respond_to do |format|
      format.json { render json: {estado: estado, mensaje: mensaje, activo: AdminAssetSerializer.new(asset)}, root: false }
    end
  end

  def historical
    proceedings = Proceeding.includes(:user).joins(:asset_proceedings).where(asset_proceedings: {asset_id: @asset.id}).order(created_at: :desc)
    respond_to do |format|
      format.json { render json: view_context.proceedings_json(proceedings), root: false }
    end
  end

  # search by code and description
  def autocomplete
    assets = view_context.search_asset_subarticle(Asset, params[:q])
    respond_to do |format|
      format.json { render json: view_context.assets_json(assets) }
    end
  end

  def depreciacion
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset
      @asset = Asset.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def asset_params
      if action_name == 'create'
        # params[:asset][:user_id] = current_user.id
        params.require(:asset).permit(:code, :code_old, :detalle, :medidas,
                                      :material, :color, :marca, :modelo,
                                      :serie, :precio, :auxiliary_id, :user_id,
                                      :state, :seguro, :ubicacion_id)
      else
        params.require(:asset).permit(:code, :code_old, :detalle, :medidas,
                                      :material, :color, :marca, :modelo,
                                      :serie, :precio, :auxiliary_id, :state,
                                      :description_decline,
                                      :reason_decline, :decline_user_id,
                                      :seguro, :ubicacion_id)
      end
    end
end
