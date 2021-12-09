module Almacenes
  class IngresoSerializer < ActiveModel::Serializer
    has_one :supplier, serializer: Almacenes::ProveedorSerializer
    has_many :entry_subarticles, each_serializer: Almacenes::IngresoItemSerializer
    attributes :id, :nro_nota_ingreso, :nro_nota_ingreso, :reingreso, :c31, :c31_fecha,
               :delivery_note_number, :delivery_note_date, :invoice_number, :invoice_autorizacion,
               :invoice_date, :subtotal, :descuento, :total, :supplier, :tipo_ingreso, :entidad_donante, :entry_subarticles

    def c31_fecha
      object.c31_fecha.present? ? I18n.l(object.c31_fecha) : ''
    end

    def note_entry_date
      object.note_entry_date.present? ? I18n.l(object.note_entry_date) : ''
    end

    def delivery_note_date
      object.delivery_note_date.present? ? I18n.l(object.delivery_note_date) : ''
    end

    def invoice_date
      object.invoice_date.present? ? I18n.l(object.invoice_date) : ''
    end
  end
end