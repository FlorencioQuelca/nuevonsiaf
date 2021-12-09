class Gestion < ActiveRecord::Base

  belongs_to :user

  validates :anio, presence: true,
                   uniqueness: true

  scope :gestion, ->(gestion) { where('EXTRACT(YEAR FROM COALESCE(factura_fecha, nota_entrega_fecha)) = ?', gestion) }


  # Retorna el año de la gestión actual que es la última gestión que no está cerrada
  def self.actual
    gestion_actual.anio rescue ''
  end

  def self.cerrar_gestion(fecha, user)
    gestion = find_by(anio: fecha.year)
    gestion.cerrado = true
    gestion.fecha_cierre = DateTime.now
    gestion.user_id = user.id if user.present?
    gestion.save!
  end

  def self.cerrar_gestion_actual(user)
    if self.actual.present?
      # TODO calcular el 31 de diciembre de ese año
      # guardar los resultados en una tabla intermedia
      fecha = Date.strptime(self.actual.to_s, '%Y')
      self.transaction do
        Asset.cerrar_gestion_actual(fecha.end_of_year)
        Gestion.cerrar_gestion(fecha.end_of_year, user)
      end
    else
      # TODO falta establecer la gestión actual
    end
  end

  def self.gestion_abierto
    where(cerrado: false).order(:anio)
  end

  # Retorna el objeto gestión actual
  def self.gestion_actual
    gestion_abierto.first rescue nil
  end

  def self.set_columns
    h = ApplicationController.helpers
    [h.get_column(self, 'anio'), h.get_column(self, 'cerrado'), h.get_column(self, 'fecha_cierre'), h.get_column(self, 'usuario')]
  end

  def self.array_model(sort_column, sort_direction, page, per_page, sSearch, search_column, current_user = '')
    array = order("#{sort_column} #{sort_direction}")
    array = array.page(page).per_page(per_page) if per_page.present?
    if sSearch.present?
      if search_column.present?
        array =
          if search_column == 'usuario'
            array = array.joins(:user).where("users.name like :search", search: "%#{sSearch}%")
          else
            array = array.where("#{search_column} like :search", search: "%#{sSearch}%")
          end
      else
        array = array.joins(:user).where("anio LIKE ? OR cerrado LIKE ? OR fecha_cierre LIKE ? OR users.name LIKE ?", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%", "%#{sSearch}%")
      end
    end
    array
  end

  def self.to_csv
    columns = %w(anio estado fecha_cierre usuario)
    h = ApplicationController.helpers
    CSV.generate do |csv|
      csv << columns.map { |c| Department.human_attribute_name(c) }
      all.each do |ufv|
        a = Array.new
        a << ufv.anio
        a << (ufv.cerrado ? 'Cerrado' : 'Abierto')
        a << ufv.fecha_cierre
        a << ufv.nombre_usuario
        csv << a
      end
    end
  end

  # Genera las gestiones relacionadas a los ingresos de los activos migrados.
  def self.generar_gestiones_migracion
    Ingreso.obtiene_gestiones.each do |anio|
      find_or_create_by(anio: anio.gestion)
    end
  end

  # Verificar si una gestión es la gestión actual
  def gestion_actual?
    Gestion.gestion_actual == self
  end

  #retorna el nombre del usuario que cerro la gestión
  def nombre_usuario
    user.present? ? user.name : ""
  end

  #retorna el cargo del usuario que cerro la gestión
  def cargo_usuario
    user.present? ? user.title : ""
  end

  # Obtiene la fecha del primer ingreso de activos
  def inicio_de_los_tiempos
    fecha = Ingreso.minimum(:factura_fecha)
    fecha.strftime("%d-%m-%Y")
  end

  def primer_dia_gestion
    "01-01-#{ anio }" if anio.present?
  end

  def ultimo_dia_gestion
    "31-12-#{ anio }" if anio.present?
  end

end
