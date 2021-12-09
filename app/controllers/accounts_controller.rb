class AccountsController < ApplicationController
  load_and_authorize_resource
  before_action :set_account, only: [:show, :edit, :update, :destroy, :change_status]

  # GET /accounts
  # GET /accounts.json
  def index
    format_to('accounts', AccountsDatatable)
  end

  # GET /accounts/1
  # GET /accounts/1.json

  def show
    lista_auxiliares = @account.retorna_auxiliares
    lista_activos = @account.retorna_activos
    monto_activos = lista_activos.inject(0.0){ |sum, x| sum + x.precio }
    @data = {
      id: @account.id,
      lista_auxiliares: ActiveModel::ArraySerializer.new(lista_auxiliares, each_serializer: AuxiliaryAccountSerializer),
      lista_activos: ActiveModel::ArraySerializer.new(lista_activos, each_serializer:AssetAccountSerializer),
      cuenta: AccountSerializer.new(@account),
      monto_activos: monto_activos,
      cantidad_activos: lista_activos.size,
      urls: {
        list: accounts_path,
        show_account: api_account_path(@account),
        show_auxiliar: auxiliary_path,
        pdf_activos: activos_account_path(@account, format: :pdf),
        pdf_auxiliares: auxiliares_account_path(@account, format: :pdf)
      }
    }
  end

  # GET /accounts/new
  def new
    @account = Account.new
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # GET /accounts/1/edit
  def edit
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to accounts_url, notice: t('general.created', model: Account.model_name.human) }
        format.json { render action: 'show', status: :created, location: @account }
      else
        format.html { render action: 'form' }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounts_url, notice: t('general.updated', model: Account.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'form' }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @account.change_status unless @account.verify_assignment
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: t('general.destroy', name: @account.name) }
      format.json { head :no_content }
    end
  end

  def auxiliares
    @data = @account.retorna_auxiliares
    @cantidad_activos = @account.retorna_activos.size
    @monto_activos = @account.retorna_activos.inject(0.0){ |sum, x| sum + x.precio }
    respond_to do |format|
      format.pdf do
        filename = 'auxiliares'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'accounts/auxiliares.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml'} },
               footer: { html: { template: 'shared/footer.pdf.haml'} }
      end
    end
  end

  def activos
    @data = @account.retorna_activos
    @monto_activos = @account.retorna_activos.inject(0.0){ |sum, x| sum + x.precio }
    respond_to do |format|
      format.pdf do
        filename = 'activos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'accounts/activos.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml'} },
               footer: { html: { template: 'shared/footer.pdf.haml'} }
        end
      end
   end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:code, :name, :vida_util, :depreciar, :actualizar)
    end
end
