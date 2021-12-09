class SuppliersController < ApplicationController
  load_and_authorize_resource
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  # GET /suppliers
  def index
    format_to('suppliers', SuppliersDatatable)
  end

  # GET /suppliers/1
  def show
    link_pdf_note_entry =
      if current_user.is_admin_store? || current_user.is_super_admin?
        note_entries_supplier_path(@supplier, format: :pdf)
      end
    link_pdf_ingreso =
      if current_user.is_admin? || current_user.is_super_admin?
        ingresos_supplier_path(@supplier,format: :pdf)
      end

      @data = {
        id: @supplier.id,
        urls: {
          show: api_supplier_path(@supplier),
          edit: edit_supplier_path(@supplier),
          list: suppliers_path,
          pdf_note_entry: link_pdf_note_entry,
          pdf_ingreso: link_pdf_ingreso
      }
    }
  end

  def note_entries
    @note_entries = @supplier.note_entries
    respond_to do |format|
      format.pdf do
        filename= 'note_entries'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'suppliers/note_entries.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml'} },
               footer: { html: { template: 'shared/footer.pdf.haml'} }
      end
    end
  end

  def ingresos
    @ingresos = @supplier.ingresos
    respond_to do |format|
      format.pdf do
        filename= 'ingresos'
        render pdf: filename,
               disposition: 'attachment',
               layout: 'pdf.html',
               template: 'suppliers/ingresos.pdf.haml',
               orientation: 'Portrait',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml'} },
               footer: { html: { template: 'shared/footer.pdf.haml'} }
      end
    end
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
    render :form
  end

  # GET /suppliers/1/edit
  def edit
    render :form
  end

  # POST /suppliers
  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to suppliers_url, notice: t('general.created', model: Supplier.model_name.human)
    else
      render :form
    end
  end

  # PATCH/PUT /suppliers/1
  def update
    if @supplier.update(supplier_params)
      redirect_to @supplier, notice: 'Supplier was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /suppliers/1
  def destroy
    @supplier.destroy
    redirect_to suppliers_url, notice: 'Supplier was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def supplier_params
      params.require(:supplier).permit(:name, :nit, :telefono, :contacto)
    end
end
