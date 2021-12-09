class SegurosController < ApplicationController
  load_and_authorize_resource
  before_action :set_seguro, only: [:show, :edit, :update, :destroy, :asegurar,
                                    :incorporaciones, :activos, :resumen]
  before_action :set_usuario, only: [:create]

  # GET /seguros
  # GET /seguros.json
  def index
    format_to('seguros', SegurosDatatable)
  end

  # GET /seguros/1
  # GET /seguros/1.json
  def show
    activos_ids = @seguro.assets.try(:ids)
    activos = Asset.todos.where(id: activos_ids).order(code: :asc)
    sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
    resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name").order("nombre")
    sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
    @data = {
      titulo: 'Seguro',
      seguro: SeguroSerializer.new(@seguro),
      activos: ActiveModel::ArraySerializer.new(activos, each_serializer: AssetSerializer),
      sumatoria: sumatoria,
      resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
      sumatoria_resumen: sumatoria_resumen,
      incorporaciones: @seguro.incorporaciones_json,
      urls: {
        listado_seguros: seguros_path,
        asegurar: asegurar_seguro_path(@seguro),
        incorporaciones:  incorporaciones_seguro_path(@seguro),
        activos: activos_seguro_path(@seguro, format: :pdf),
        resumen: resumen_seguro_path(@seguro, format: :pdf)
      }
    }
  end

  def new
    @data = {
      titulo: 'Obtener Cotización',
      urls: {
        activos: api_activos_path(format: :json),
        listado_seguros: seguros_path,
        seguros: api_seguros_path
      }
    }
  end

  def edit
    seguro_padre = @seguro.seguro
    activos_ids = @seguro.assets.try(:ids)
    activos = Asset.todos.where(id: activos_ids).order(code: :asc)
    sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
    resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name").order("nombre")
    sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
    @data = {
      titulo: 'Editar Seguro',
      seguro: SeguroSerializer.new(@seguro),
      numero_contrato: seguro_padre.present? ? seguro_padre.numero_contrato : nil,
      activos: ActiveModel::ArraySerializer.new(activos, each_serializer: AssetSerializer),
      sumatoria: sumatoria,
      resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
      sumatoria_resumen: sumatoria_resumen,
      urls: {
        proveedores: api_proveedores_path(format: :json),
        activos: api_activos_path(format: :json),
        seguros: seguros_path,
        seguro: seguro_path(@seguro)
      }
    }
  end

  def asegurar
    seguro_padre = @seguro.seguro
    activos_ids = @seguro.assets.try(:ids)
    activos = Asset.todos.where(id: activos_ids).order(:code)
    sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
    resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name").order("nombre")
    sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
    @data = {
      titulo: 'Asegurar',
      seguro: @seguro,
      numero_contrato: seguro_padre.present? ? seguro_padre.numero_contrato : nil,
      activos: ActiveModel::ArraySerializer.new(activos, each_serializer: AssetSerializer),
      sumatoria: sumatoria,
      resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
      sumatoria_resumen: sumatoria_resumen,
      urls: {
        proveedores: api_proveedores_path(format: :json),
        listado_seguros: seguros_path,
        activos: api_activos_path(format: :json),
        asegurar: asegurar_seguro_path(@seguro),
        seguros: api_seguros_path
      }
    }
  end

  def incorporaciones
    @data = {
      titulo: 'Incorporar Activos',
      seguro: SeguroSerializer.new(@seguro),
      urls: {
        activos: api_activos_path(format: :json),
        listado_seguros: seguros_path,
        seguros: api_seguros_path,
        sin_seguro: sin_seguro_vigente_api_activo_path(@seguro)
      }
    }
    render template: "seguros/new"
  end

  def activos
    activos_ids = @seguro.assets.try(:ids)
    @activos = Asset.todos.where(id: activos_ids).order(code: :asc)
    @sumatoria = @activos.inject(0.0) { |total, activo| total + activo.precio }
    respond_to do |format|
      format.pdf do
        filename = 'reporte-de-activos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'seguros/activos.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  def resumen
    activos_ids = @seguro.assets.try(:ids)
    activos = Asset.todos.where(id: activos_ids).order(code: :asc)
    @resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name").order("nombre")
    @sumatoria_resumen = @resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
    respond_to do |format|
      format.pdf do
        filename = 'resumen-de-activos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'seguros/resumen.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # POST /seguros
  # POST /seguros.json
  def create
    @seguro = Seguro.new(seguro_params)
    @seguro.user = @usuario
    respond_to do |format|
      if @seguro.save
        format.html { redirect_to @seguro, notice: 'Seguro creado exitosamente.' }
        format.json { render json: @seguro, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @seguro.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seguros/1
  # PATCH/PUT /seguros/1.json
  def update
    respond_to do |format|
      if @seguro.update(seguro_params)
        format.html { redirect_to @seguro, notice: 'Seguro was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @seguro.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seguros/1
  # DELETE /seguros/1.json
  def destroy
    @seguro.destroy
    respond_to do |format|
      format.html { redirect_to seguros_url }
      format.json { head :no_content }
    end
  end

  private

  def set_seguro
    @seguro = Seguro.find(params[:id])
  end

  def set_usuario
    @usuario = current_user
  end

  def seguro_params
    params.require(:seguro)
          .permit(:supplier_id, :user_id, :factura_numero,
                  :factura_autorizacion, :factura_fecha, :factura_monto, :tipo,
                  :numero_poliza, :numero_contrato, :fecha_inicio_vigencia,
                  :fecha_fin_vigencia, :baja_logica)
  end
end
