module SegurosHelper
  def seguros_datos(seguro)
    datos = []
    seguro_padre = seguro.seguro || seguro
    if seguro_padre.numero_poliza
      datos << ['Póliza', seguro_padre.numero_poliza]
    end
    if seguro.numero_contrato
      datos << ['Número de contrato', seguro.numero_contrato]
    end
    if seguro_padre.fecha_inicio_vigencia
      datos << ['Desde', l(seguro_padre.fecha_inicio_vigencia, format: :version)]
    end
    if seguro_padre.fecha_fin_vigencia
      datos << ['Hasta', l(seguro_padre.fecha_fin_vigencia, format: :version)]
    end
    if seguro.proveedor_nombre.present?
      datos << ['Proveedor', seguro.proveedor_nombre]
    end
    if seguro.proveedor_nit.present?
      datos << ['NIT', seguro.proveedor_nit]
    end
    if seguro.proveedor_telefono.present?
      datos << ['Teléfono(s)', seguro.proveedor_telefono]
    end
    if seguro.factura_numero
      datos << ['Número de factura', seguro.factura_numero]
    end
    if seguro.factura_autorizacion
      datos << ['Número de autorización', seguro.factura_autorizacion]
    end
    if seguro.factura_fecha
      datos << ['Fecha factura', l(seguro.factura_fecha)]
    end
    if seguro.factura_monto
      datos << ['Monto factura', seguro.factura_monto]
    end
    datos
  end
end
