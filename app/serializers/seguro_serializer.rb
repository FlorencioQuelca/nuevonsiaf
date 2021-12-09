class SeguroSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :supplier, :user, :numero_poliza, :numero_contrato,
             :factura_numero, :factura_autorizacion, :factura_fecha,
             :factura_monto, :fecha_inicio_vigencia, :fecha_fin_vigencia,
             :baja_logica, :proveedor, :proveedor_nit, :proveedor_telefono,
             :state, :tipo, :seguro_id, :urls
  has_many :assets, serializer: AssetSerializer

  def factura_fecha
    object.factura_fecha.to_time.iso8601 if object.factura_fecha.present?
  end

  def fecha_inicio_vigencia
    object.fecha_inicio_vigencia.to_time.iso8601 if object.fecha_inicio_vigencia.present?
  end

  def fecha_fin_vigencia
    object.fecha_fin_vigencia.to_time.iso8601 if object.fecha_fin_vigencia.present?
  end

  def proveedor
    object.proveedor_nombre
  end

  def proveedor_nit
    object.proveedor_nit
  end

  def proveedor_telefono
    object.proveedor_telefono
  end

  def urls
    { edit: edit_seguro_path(object)}
  end
end
