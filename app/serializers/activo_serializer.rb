class ActivoSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :codigo, :factura, :fecha, :descripcion, :cuenta, :precio, :lugar

  def fecha
    I18n.l(object.fecha_ingreso) if object.fecha_ingreso
  end
end
