class Baja < ActiveRecord::Base
  include Autoincremento
  has_many :assets
  belongs_to :user

  MOTIVOS = [
    'Disposición definitiva de bienes',
    'Hurto, robo o pérdida fortuita',
    'Mermas',
    'Vencimientos, descomposiciones, alteraciones o deterioros',
    'Inutilización',
    'Obsolescencia',
    'Desmantelamiento total o parcial de edificaciones, excepto el terreno que no será dado de baja',
    'Siniestros',
    'Otros'
  ]

  # método que verifica si baja tiene un código.
  def tiene_codigo?
    numero.present?
  end

  # Método para obtener el siguiente codigo de activo.
  def self.obtiene_siguiente_codigo(fecha)
    fecha = fecha.present? ? fecha : Date.today
    bajas_gestion = Baja.where(fecha: fecha.beginning_of_year..fecha.end_of_year)
    bajas_gestion.empty? ? 1 : bajas_gestion.maximum(:numero) + 1
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        type_search = "baja.#{search_column}"
        array = array.where("#{type_search} like :search", search: "%#{sSearch}%")
      else
        array = array.where("bajas.fecha LIKE ? OR bajas.numero LIKE ? OR bajas.observacion LIKE ? OR bajas.motivo LIKE ? OR bajas.documento_cite LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.set_columns
    h = ApplicationController.helpers
    columnas = [h.get_column(self, 'numero'), h.get_column(self, 'documento'), h.get_column(self, 'fecha')]

    if Rails.application.secrets.interoperabilidad_plantillas.present?
      columnas << h.get_column(self, 'documento_cite')
    end
    columnas
  end

  def self.to_csv
    columns = %w(codigo motivo documento fecha_documento fecha)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Ingreso.human_attribute_name(c) }
      all.each do |baja|
        a = Array.new
        a << baja.numero
        a << baja.motivo
        a << baja.documento
        a << baja.fecha_documento
        a << baja.fecha
        csv << a
      end
    end
  end
end
