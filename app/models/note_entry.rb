class NoteEntry < ActiveRecord::Base
  include Autoincremento

  default_scope {where(invalidate: false)}

  scope :del_anio_por_fecha_factura, -> (fecha) { where(invoice_date: fecha.beginning_of_year..fecha.end_of_year) }
  scope :mayor_a_fecha_factura, -> (fecha) { where('invoice_date > ?', fecha) }
  scope :menor_igual_a_fecha_factura, -> (fecha) { where('invoice_date <= ?', fecha) }
  scope :con_fecha_factura, -> { where.not('invoice_date is null') }
  scope :con_nro_nota_ingreso, -> { where('nro_nota_ingreso != ?',0)}

  belongs_to :supplier
  belongs_to :user, required: true

  has_many :entry_subarticles
  accepts_nested_attributes_for :entry_subarticles

  has_paper_trail

  before_save :set_note_entry_date

  validates :documento_id, uniqueness: true, if: 'documento_id.present?'
  validates :supplier, presence: true, if: 'reingreso == 0'

  def supplier_name
    supplier.present? ? supplier.name : ''
  end

  def supplier_nit
    supplier.present? ? supplier.nit : ''
  end

  def user_name
    user.present? ? user.name : ''
  end

  def user_title
    user.present? ? user.title : ''
  end

  def note_number(number)
    number.present? ? "##{number}" : ''
  end

  def note_date(date)
    date.present? ? I18n.l(date) : ''
  end

  def get_delivery_note_number
    invoice = ''
    if delivery_note_number.present?
      invoice += "#{delivery_note_number}"
    elsif delivery_note_date.present?
      invoice += "#{I18n.l delivery_note_date, format: :default}"
    end
  end

  def get_invoice_number
    invoice = ''
    if invoice_number.present?
      invoice += "#{invoice_number}"
    elsif invoice_date.present?
      invoice += "#{I18n.l invoice_date, format: :default}"
    end
    invoice.strip
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    orden = "#{sort_column} #{sort_direction}"
    case sort_column
    when "note_entries.note_entry_date"
      orden += ", note_entries.nro_nota_ingreso #{sort_direction}, note_entries.incremento_alfabetico #{sort_direction}"
    when "note_entries.nro_nota_ingreso"
      orden += ", note_entries.incremento_alfabetico #{sort_direction}"
    end
    array = joins(:user, :supplier).order(orden)
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = %w(users suppliers).include?(search_column) ? "#{search_column}.name" : "note_entries.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("note_entries.nro_nota_ingreso LIKE ? OR suppliers.name LIKE ? OR users.name LIKE ? OR note_entries.total LIKE ? OR note_entries.documento_cite LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    columnas = [h.get_column(self, 'nro_nota_ingreso'), h.get_column(self, 'suppliers'), h.get_column(self, 'users'), h.get_column(self, 'total'), h.get_column(self, 'delivery_note_date')]
    if Rails.application.secrets.interoperabilidad_plantillas.present?
      columnas << h.get_column(self, 'cite_ems')
    end
    columnas
  end

  def self.to_csv
    columns = %w(id suppliers users total delivery_note_date)
    CSV.generate do |csv|
      csv << columns.map { |c| self.human_attribute_name(c) }
      all.each do |note_entry|
        a = note_entry.attributes.values_at(*columns)
        a.pop(4)
        a.push(note_entry.supplier_name)
        a.push(note_entry.user_name)
        a.push(note_entry.total)
        a.push(note_entry.note_date(note_entry.delivery_note_date))
        csv << a
      end
    end
  end

  def change_date_entries
    entry_subarticles.each do |entry|
      entry.set_date_value
      entry.save
    end
  end

  # Anula una Nota de Entrada, y también los subartículos asociados al mismo.
  # Es necesario especificar el motivo de la anulación
  def invalidate_note(message="")
    transaction do
      update(invalidate: true, message: message)
      entry_subarticles.invalidate_entries
    end
  end

  def obtiene_nro_nota_ingreso
    if !incremento_alfabetico.present?
      "#{nro_nota_ingreso}"
    else
      "#{nro_nota_ingreso}-#{incremento_alfabetico}"
    end
  end

  def self.nro_nota_ingreso_anterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_factura(fecha).menor_igual_a_fecha_factura(fecha).where.not(nro_nota_ingreso: 0).maximum(:nro_nota_ingreso)
  end

  def self.nro_nota_ingreso_posterior(fecha)
    fecha = fecha.to_date
    self.del_anio_por_fecha_factura(fecha).mayor_a_fecha_factura(fecha).where.not(nro_nota_ingreso: 0).minimum(:nro_nota_ingreso)
  end

  def tiene_nro_nota_ingreso?
    nro_nota_ingreso > 0 && invoice_date.present?
  end

  def self.nro_nota_ingreso_posterior_regularizado(fecha)
    fecha = fecha.to_date
    nro_nota_ingreso = self.nro_nota_ingreso_anterior(fecha)
    self.del_anio_por_fecha_factura(fecha).mayor_a_fecha_factura(fecha).where(nro_nota_ingreso: nro_nota_ingreso).first.try(:incremento_alfabetico)
  end

  def self.obtiene_siguiente_nro_nota_ingreso(fecha)
    codigo_numerico = nil
    codigo_alfabetico = nil
    respuesta_hash = Hash.new
    if fecha.present?
      fecha = fecha.to_date
      nro_nota_anterior = NoteEntry.nro_nota_ingreso_anterior(fecha)
      nro_nota_posterior = NoteEntry.nro_nota_ingreso_posterior(fecha)
      if nro_nota_anterior.present? && !nro_nota_posterior.present?
        respuesta_hash[:codigo_numerico] = nro_nota_anterior.to_i + 1
      elsif !nro_nota_anterior.present? && !nro_nota_posterior.present?
        respuesta_hash[:codigo_numerico] = 1
      elsif nro_nota_anterior.present? && nro_nota_posterior.present?
        diferencia = nro_nota_posterior - nro_nota_anterior
        if diferencia > 1
          respuesta_hash[:codigo_numerico] = nro_nota_anterior.to_i + 1
        else
          if !Rails.application.secrets.interoperabilidad_plantillas.present?
            inc_alfabetico = NoteEntry.nro_nota_ingreso_posterior_regularizado(fecha)
            if inc_alfabetico.present?
              nota_anterior = NoteEntry.del_anio_por_fecha_factura(fecha).con_nro_nota_ingreso.menor_igual_a_fecha_factura(fecha).order(invoice_date: :desc, nro_nota_ingreso: :desc, incremento_alfabetico: :desc).first
              nota_posterior = NoteEntry.del_anio_por_fecha_factura(fecha).con_nro_nota_ingreso.mayor_a_fecha_factura(fecha).order(invoice_date: :asc, nro_nota_ingreso: :asc, incremento_alfabetico: :asc).first
              respuesta_hash[:tipo_respuesta] = "alerta"
              respuesta_hash[:fecha] = fecha.strftime("%d/%m/%Y")
              respuesta_hash[:nro_nota_anterior] = nota_anterior.obtiene_nro_nota_ingreso
              respuesta_hash[:fecha_nota_anterior] = nota_anterior.invoice_date.strftime("%d/%m/%Y") if nota_anterior.invoice_date.present?
              respuesta_hash[:nro_nota_posterior] =  nota_posterior.obtiene_nro_nota_ingreso
              respuesta_hash[:fecha_nota_posterior] = nota_posterior.invoice_date.strftime("%d/%m/%Y") if nota_posterior.invoice_date.present?
            else
              max_incremento_alfabetico = NoteEntry.where(nro_nota_ingreso: nro_nota_anterior).order(incremento_alfabetico: :desc).first.incremento_alfabetico
              codigo_numerico = nro_nota_anterior.to_i
              codigo_alfabetico = max_incremento_alfabetico.present? ? max_incremento_alfabetico.next : "A"
              ultima_fecha = NoteEntry.del_anio_por_fecha_factura(fecha).order(invoice_date: :desc).first.try(:invoice_date)
              ultima_fecha = ultima_fecha.strftime("%d/%m/%Y") if ultima_fecha.present?
              respuesta_hash[:tipo_respuesta] = "confirmacion"
              respuesta_hash[:nro_nota_ingreso] = codigo_alfabetico.present? ? "#{codigo_numerico}-#{codigo_alfabetico}" : "#{codigo_numerico}"
              respuesta_hash[:codigo_numerico] = codigo_numerico
              respuesta_hash[:codigo_alfabetico] = codigo_alfabetico
              respuesta_hash[:ultima_fecha] = ultima_fecha
            end
          else
            max_nro_alfabetico = NoteEntry.where(invoice_date: fecha).order(nro_nota_ingreso: :desc, incremento_alfabetico: :desc).first
            if max_nro_alfabetico.present?
              codigo_numerico = max_nro_alfabetico.nro_nota_ingreso.to_i
              codigo_alfabetico = max_nro_alfabetico.incremento_alfabetico.present? ? max_nro_alfabetico.incremento_alfabetico.next : "A"
              respuesta_hash[:codigo_numerico] = codigo_numerico
              respuesta_hash[:codigo_alfabetico] = codigo_alfabetico
            else
              nro_nota_posterior_max = self.del_anio_por_fecha_factura(fecha).where.not(nro_nota_ingreso: 0).maximum(:nro_nota_ingreso)
              if nro_nota_posterior_max.present?
                respuesta_hash[:codigo_numerico] = nro_nota_posterior_max.to_i + 1
              end
            end

          end
        end
      else
        if nro_nota_posterior > 1
          respuesta_hash[:codigo_numerico] = nro_nota_posterior.to_i - 1
        else
          if Rails.application.secrets.interoperabilidad_plantillas.present?
            nro_nota_posterior_max = self.del_anio_por_fecha_factura(fecha).where.not(nro_nota_ingreso: 0).maximum(:nro_nota_ingreso)
            if nro_nota_posterior_max.present?
              respuesta_hash[:codigo_numerico] = nro_nota_posterior_max.to_i + 1
            end
          else
            respuesta_hash[:tipo_respuesta] = "alerta"
            respuesta_hash[:mensaje] = "No se puede introducir una nota de ingreso para la fecha, por favor contactese con el administrador del sistema."
          end
        end
      end
    end
    respuesta_hash
  end

  def actualizar(datos)
    proveedor = datos["supplier"]
    ingreso_items = datos["entry_subarticles"]
    ingreso = datos.except("entry_subarticles", "supplier")
    nuevos_ids = ingreso_items.map{|i| i["id"]}
    actuales_ids = entry_subarticles.map(&:id)
    para_eliminar_ids = actuales_ids - nuevos_ids
    transaction do
      update_attributes(ingreso)
      ingreso_items.each do |ingreso_item|
        ingreso_item["date"] = get_first_date
        if ingreso_item["id"].present?
          entry_subarticle = EntrySubarticle.find(ingreso_item["id"])
          transaction do
            entry_subarticle.update_attributes(ingreso_item.except("subarticle"))
          end
        else
          ingreso_item["subarticle_id"] = ingreso_item["subarticle"]["id"]
          transaction do
            EntrySubarticle.create(ingreso_item.except("subarticle"))
          end
        end
      end
      para_eliminar_ids.each do |id|
          entry_subarticle = EntrySubarticle.find(id)
          transaction do
            entry_subarticle.update_attributes(invalidate: true)
          end
      end
    end
    [true, 'Se ha guardado sus datos con exito.']
  rescue
    [false, 'Se ha producido un error']
  end

  protected

  def set_note_entry_date
    self.note_entry_date = get_first_date
  end

  def get_first_date
    if invoice_date
      first_date = invoice_date
    elsif delivery_note_date
      first_date = delivery_note_date
    else
      first_date = Time.now.to_date
    end
    first_date.to_date
  end

end
