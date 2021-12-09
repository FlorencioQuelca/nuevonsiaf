class ApiTokensController < ApplicationController
  load_and_authorize_resource
  require 'json_web_token'
  before_action :set_api_token, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /api_tokens
  # GET /api_tokens.json
  def index
    # @api_tokens = ApiToken.all

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @api_tokens }
    # end
    format_to('api_tokens', ApiTokensDatatable)
  end

  # GET /api_tokens/1
  # GET /api_tokens/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_token }
    end
  end

  # GET /api_tokens/new
  def new
    @api_token = ApiToken.new
  end

  # GET /api_tokens/1/edit
  def edit
  end

  # POST /api_tokens
  # POST /api_tokens.json
  def create
    @api_token = ApiToken.new(api_token_params)
    payload = {email:api_token_params[:email]}
    exp =  DateTime.parse(api_token_params[:fecha_expiracion])
    @api_token.token = JsonWebToken.encode(payload, exp)
    # @api_token.estado = '1'

    respond_to do |format|
      if @api_token.save
        format.html { redirect_to @api_token, notice: 'Api token was successfully created.' }
        format.json { render json: @api_token, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @api_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api_tokens/1
  # PATCH/PUT /api_tokens/1.json
  def update
    respond_to do |format|
      if @api_token.update(api_token_params)
        format.html { redirect_to @api_token, notice: 'Api token was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @api_token.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @api_token.change_status unless @api_token.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # DELETE /api_tokens/1
  # DELETE /api_tokens/1.json
  def destroy
    @api_token.destroy
    respond_to do |format|
      format.html { redirect_to api_tokens_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_token
      @api_token = ApiToken.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_token_params
      params.require(:api_token).permit(:email, :nombre, :fecha_expiracion)
    end
end
