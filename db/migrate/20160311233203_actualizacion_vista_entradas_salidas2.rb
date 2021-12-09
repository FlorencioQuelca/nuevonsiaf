class ActualizacionVistaEntradasSalidas2 < ActiveRecord::Migration
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW entradas_salidas AS

      -- SELECT @id:=@id+1 as id, tabla.* FROM (
      SELECT es.id,
        es.subarticle_id,
        r.delivery_date as fecha,
        '' as factura,
        CAST(null as DATE) as nota_entrega,
        r.nro_solicitud as nro_pedido,
        concat(u.name, ' - ', u.title) as detalle,
        -- u.name as detalle,
        -es.total_delivered as cantidad,
        -- 0 as saldo,
        0 as costo_unitario,
        -- 0 as costo_saldo,
        es.request_id as modelo_id,
        'salida' as tipo,
        r.created_at
      FROM requests r INNER JOIN subarticle_requests es ON r.id=es.request_id
              INNER JOIN users u ON r.user_id=u.id
      WHERE r.invalidate = 0 AND es.invalidate = 0

      UNION

      SELECT es.id,
        es.subarticle_id,
        ne.note_entry_date as fecha,
        ne.invoice_number as factura,
        ne.delivery_note_date as nota_entrega,
        '' as nro_pedido,
        IF(ne.supplier_id, (SELECT s.name FROM suppliers s WHERE s.id=ne.supplier_id), null) as detalle,
        es.amount as cantidad,
        -- 0 as saldo,
        es.unit_cost as costo_unitario,
        -- es.unit_cost*es.amount as costo_saldo,
        es.note_entry_id as modelo_id,
        'entrada' as tipo,
        es.created_at
      FROM entry_subarticles es LEFT JOIN note_entries ne ON es.note_entry_id=ne.id
                    -- INNER JOIN suppliers s ON ne.supplier_id = s.id
      WHERE es.invalidate = 0

      ORDER BY subarticle_id, fecha, cantidad DESC, created_at
      -- ) as tabla, (SELECT @id:=0) as t;
    )
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS entradas_salidas;"
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW entradas_salidas AS

      -- SELECT @id:=@id+1 as id, tabla.* FROM (
      SELECT es.id,
        es.subarticle_id,
        r.delivery_date as fecha,
        '' as factura,
        CAST(null as DATE) as nota_entrega,
        r.nro_solicitud as nro_pedido,
        concat(u.name, ' - ', u.title) as detalle,
        -- u.name as detalle,
        -es.total_delivered as cantidad,
        -- 0 as saldo,
        0 as costo_unitario,
        -- 0 as costo_saldo,
        es.request_id as modelo_id,
        'salida' as tipo,
        r.created_at
      FROM requests r INNER JOIN subarticle_requests es ON r.id=es.request_id
              INNER JOIN users u ON r.user_id=u.id
      WHERE r.invalidate = 0 AND es.invalidate = 0

      UNION

      SELECT es.id,
        es.subarticle_id,
        es.date as fecha,
        ne.invoice_number as factura,
        ne.delivery_note_date as nota_entrega,
        '' as nro_pedido,
        IF(ne.supplier_id, (SELECT s.name FROM suppliers s WHERE s.id=ne.supplier_id), null) as detalle,
        es.amount as cantidad,
        -- 0 as saldo,
        es.unit_cost as costo_unitario,
        -- es.unit_cost*es.amount as costo_saldo,
        es.note_entry_id as modelo_id,
        'entrada' as tipo,
        es.created_at
      FROM entry_subarticles es LEFT JOIN note_entries ne ON es.note_entry_id=ne.id
                    -- INNER JOIN suppliers s ON ne.supplier_id = s.id
      WHERE es.invalidate = 0

      ORDER BY subarticle_id, fecha, cantidad DESC, created_at
      -- ) as tabla, (SELECT @id:=0) as t;
    )
  end

end
