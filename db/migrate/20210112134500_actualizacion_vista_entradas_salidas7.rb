class ActualizacionVistaEntradasSalidas7 < ActiveRecord::Migration
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW entradas_salidas AS

      SELECT es.id,
        es.subarticle_id,
        r.delivery_date as fecha,
        '' as factura,
        CAST(null as DATE) as nota_entrega,
        r.nro_solicitud as nro_pedido,
        concat(u.name, ' - ', u.title) as detalle,
        -es.total_delivered as cantidad,
        0 as costo_unitario,
        es.request_id as modelo_id,
        'salida' as tipo,
        r.created_at,
        r.cite_ems as cite_ems_plantillas
      FROM requests r INNER JOIN subarticle_requests es ON r.id=es.request_id
              INNER JOIN users u ON r.user_id=u.id
      WHERE r.invalidate = 0 AND es.invalidate = 0 AND r.status = 'delivered'

      UNION

      SELECT es.id,
        es.subarticle_id,
        IFNULL(ne.note_entry_date, es.date) as fecha,
        ne.invoice_number as factura,
        ne.delivery_note_date as nota_entrega,
        '' as nro_pedido,
        IF(ne.supplier_id, (SELECT s.name FROM suppliers s WHERE s.id=ne.supplier_id), IF(ne.reingreso = 1, 'REINGRESO', IF(ne.tipo_ingreso = 'donacion_transferencia', 'DONACION O TRANSFERENCIA', 'SALDO INICIAL'))) as detalle,
        es.amount as cantidad,
        es.unit_cost as costo_unitario,
        es.note_entry_id as modelo_id,
        'entrada' as tipo,
        es.created_at,
        ne.documento_cite as cite_ems_plantillas
      FROM entry_subarticles es LEFT JOIN note_entries ne ON es.note_entry_id=ne.id
      WHERE es.invalidate = 0

      ORDER BY subarticle_id, fecha, id, cantidad DESC, created_at
    )
  end

  def down
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW entradas_salidas AS

      SELECT es.id,
        es.subarticle_id,
        r.delivery_date as fecha,
        '' as factura,
        CAST(null as DATE) as nota_entrega,
        r.nro_solicitud as nro_pedido,
        concat(u.name, ' - ', u.title) as detalle,
        -es.total_delivered as cantidad,
        0 as costo_unitario,
        es.request_id as modelo_id,
        'salida' as tipo,
        r.created_at,
        r.cite_ems as cite_ems_plantillas
      FROM requests r INNER JOIN subarticle_requests es ON r.id=es.request_id
              INNER JOIN users u ON r.user_id=u.id
      WHERE r.invalidate = 0 AND es.invalidate = 0 AND r.status = 'delivered'

      UNION

      SELECT es.id,
        es.subarticle_id,
        IFNULL(ne.note_entry_date, es.date) as fecha,
        ne.invoice_number as factura,
        ne.delivery_note_date as nota_entrega,
        '' as nro_pedido,
        IFNULL(IF(ne.supplier_id, (SELECT s.name FROM suppliers s WHERE s.id=ne.supplier_id), null), "SALDO INICIAL") as detalle,
        es.amount as cantidad,
        es.unit_cost as costo_unitario,
        es.note_entry_id as modelo_id,
        'entrada' as tipo,
        es.created_at,
        '' as cite_ems_plantillas
      FROM entry_subarticles es LEFT JOIN note_entries ne ON es.note_entry_id=ne.id
      WHERE es.invalidate = 0

      ORDER BY subarticle_id, fecha, id, cantidad DESC, created_at
    )
  end
end
