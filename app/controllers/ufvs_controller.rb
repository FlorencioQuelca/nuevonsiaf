class UfvsController < ApplicationController
  before_action :set_ufv, only: [:show, :edit, :update, :destroy]

  # GET /ufvs
  # GET /ufvs.json
  def index
    format_to('ufvs', UfvsDatatable)
  end

  # GET /ufvs/1
  # GET /ufvs/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ufv }
    end
  end

  # GET /ufvs/new
  def new
    @ufv = Ufv.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /ufvs/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /ufvs
  # POST /ufvs.json
  def create
    @ufv = Ufv.new(ufv_params)

    respond_to do |format|
      if @ufv.save
        format.html { redirect_to ufvs_url, notice: t('general.created', model: Ufv.model_name.human) }
        format.json { render json: @ufv, status: :created }
      else
        format.html { render action: 'form' }
        format.json { render json: @ufv.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ufvs/1
  # PATCH/PUT /ufvs/1.json
  def update
    respond_to do |format|
      if @ufv.update(ufv_params)
        format.html { redirect_to ufvs_url, notice: t('general.updated', model: Ufv.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @ufv.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ufvs/1
  # DELETE /ufvs/1.json
  def destroy
    @ufv.destroy
    respond_to do |format|
      format.html { redirect_to ufvs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ufv
      @ufv = Ufv.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ufv_params
      params.require(:ufv).permit(:fecha, :valor)
    end
end
