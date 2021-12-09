class NotaEntradaSerializer < ActiveModel::Serializer
  attributes :id, :nro, :nro_nota_ingreso, :empresa, :encargado, :fecha, :total,
             :nota_entrega_nro, :factura_nro, :anulado, :mensaje, :creado_el,
             :observacion, :links

  def nro
    ''
  end

  def empresa
    object.supplier_name
  end

  def encargado
    object.user_name
  end

  def fecha
    object.note_entry_date.present? ? I18n.l(object.note_entry_date) : ''
  end

  def nro_nota_ingreso
    object.obtiene_nro_nota_ingreso
  end

  def nota_entrega_nro
    object.delivery_note_number
  end

  def factura_nro
    object.invoice_number
  end

  def creado_el
    object.created_at.present? ? I18n.l(object.created_at) : ''
  end

  def anulado
    object.invalidate
  end

  def mensaje
    object.message
  end

  def links
    { show: note_entry_path(object) }
  end
end
