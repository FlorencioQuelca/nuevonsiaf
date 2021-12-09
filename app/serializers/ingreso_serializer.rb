class IngresoSerializer <ActiveModel::Serializer
  self.root = false
  attributes  :id, :numero, :nota_entrega_fecha, :nota_entrega_numero,
              :factura_numero, :name, :encargado, :factura_fecha, :supplier_id,
              :c31_numero, :baja_logica, :total, :urls

  def factura_fecha
    object.factura_fecha.present? ? I18n.l(object.factura_fecha) : ''
  end

  def nota_entrega_fecha
    object.nota_entrega_fecha.present? ? I18n.l(object.nota_entrega_fecha) : ''
  end

  def name
    object.supplier_name
  end

  def encargado
    object.user_name
  end

  def urls
    { show: ingreso_path(object) }
  end
end
