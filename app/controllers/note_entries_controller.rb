class NoteEntriesController < ApplicationController
  load_and_authorize_resource
  before_action :set_note_entry, only: [:show, :edit, :update, :destroy]
  before_action :verificar_interoperabilidad, only: [:new, :edit, :create, :update]

  # GET /note_entries
  def index
    format_to('note_entries', NoteEntriesDatatable)
  end

  # GET /note_entries/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Nota de Ingreso #{@note_entry.note_entry_date}".parameterize,
               disposition: 'attachment',
               template: 'note_entries/show.html.haml',
               # show_as_html: params[:debug].present?,
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: view_context.margin_pdf,
               header: { html: { template: 'shared/header.pdf.haml' } },
               footer: { html: { template: 'shared/footer.pdf.haml' } }
      end
    end
  end

  # GET /note_entries/new
  def new
    @note_entry = NoteEntry.new
  end

  # GET /note_entries/1/edit
  def edit
  end

  # POST /note_entries
  def create
    @note_entry = NoteEntry.new(note_entry_params)
    @note_entry.supplier_id = Supplier.get_id(params[:note_entry][:supplier_id])
    @note_entry.user_id = current_user.id
    @note_entry.reingreso = @note_entry.tipo_ingreso == 'reingreso' ? 1 : 0

    # Guardar historico de usuarios(En caso de cambios de cargo y unidad)
    @note_entry.json_usuarios = User.obtener_datos(@note_entry.user_id).to_json

    @note_entry.save
  end

  # PATCH/PUT /note_entries/1
  def update
    respond_to do |format|
      if @note_entry.update(note_entry_params)
        @note_entry.change_date_entries
        format.html { redirect_to @note_entry, notice: t('general.updated', model: NoteEntry.model_name.human) }
        format.js
      else
        format.html { render action: 'new' }
      end
    end
  end

  def get_suppliers
    render json: Supplier.search_supplier(params[:q]), root: false
  end

  def obt_cod_ingreso
    resultado = Hash.new
    if params[:d].present?
      fecha = params[:d].to_date
      if params[:n].present?
        nota_ingreso = NoteEntry.find(params[:n])
        if nota_ingreso.nro_nota_ingreso == 0 || nota_ingreso.nro_nota_ingreso == nil
          resultado = NoteEntry.obtiene_siguiente_nro_nota_ingreso(fecha)
        end
      else
        resultado = NoteEntry.obtiene_siguiente_nro_nota_ingreso(fecha)
      end
      if resultado[:tipo_respuesta] == 'confirmacion'
        resultado[:titulo] = "Confirmación de Nota de Ingreso"
      elsif resultado[:tipo_respuesta] == 'alerta'
        resultado[:titulo] = "Alerta de Nota de Ingreso"
      end
    end
    render json: resultado, root: false
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_note_entry
    @note_entry = NoteEntry.find(params[:id])
  end

  def verificar_interoperabilidad
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      redirect_to note_entries_url, alert: 'Acceso denegado'
    end
  end

  # Only allow a trusted parameter "white list" through.
  def note_entry_params
    params.require(:note_entry).permit(:delivery_note_number,
                                      :nro_nota_ingreso, :delivery_note_date,
                                      :invoice_number, :invoice_autorizacion,
                                      :c31, :invoice_date, :supplier_id,
                                      :subtotal, :total, :descuento,
                                      :observacion, :c31_fecha, :reingreso,
                                      :tipo_ingreso,
                                      :entidad_donante,
                                      entry_subarticles_attributes: [
                                      :id, :subarticle_id, :amount,
                                      :unit_cost, :total_cost
                                      ])
  end
end
