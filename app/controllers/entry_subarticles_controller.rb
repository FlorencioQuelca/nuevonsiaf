class EntrySubarticlesController < ApplicationController
  load_and_authorize_resource
  before_action :set_entry_subarticle, only: [:edit, :update]

  # GET /entry_subarticles/1/edit
  def edit
  end

  # PATCH/PUT /entry_subarticles/1
  # PATCH/PUT /entry_subarticles/1.json
  def update
    respond_to do |format|
      if @entry_subarticle.update(entry_subarticle_params)
        format.html { redirect_to subarticle_url(@entry_subarticle.subarticle), notice: t('general.updated', model: EntrySubarticle.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @entry_subarticle.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry_subarticle
      @entry_subarticle = EntrySubarticle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_subarticle_params
      params.require(:entry_subarticle).permit(:amount, :unit_cost, :total_cost, :date, :stock, :created_at)
    end
end
