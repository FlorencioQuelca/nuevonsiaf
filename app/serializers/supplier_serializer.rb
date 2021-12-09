class SupplierSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name, :nit, :telefono, :contacto, :created_at, :note_entries,
             :ingresos

  has_many :note_entries, serializer: NotaEntradaSerializer
  has_many :ingresos, serializer: IngresoSerializer

  def created_at
    I18n.l(object.created_at, format: :long ) if object.created_at.present?
  end

  def note_entries
    %w(super_admin admin_store).include?(serialization_options[:role]) ? object.note_entries : []
  end

  def ingresos
    %w(super_admin admin).include?(serialization_options[:role]) ? object.ingresos : []
  end
end
