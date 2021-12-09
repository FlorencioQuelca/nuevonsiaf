class AddProceduresReportes < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION total_salidas(subarticle_id INT, fecha DATETIME) RETURNS DECIMAL(10, 2)
      BEGIN
        DECLARE total DECIMAL(10, 2) DEFAULT 0;
        SELECT SUM(sr.total_delivered) INTO total
        FROM requests r
          INNER JOIN subarticle_requests sr ON sr.request_id = r.id
        WHERE sr.subarticle_id = subarticle_id
          AND r.invalidate = 0
          AND r.status = 'delivered'
          AND r.delivery_date <= fecha;
        RETURN COALESCE(total, 0);
      END
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION total_saldo_bs(subarticle_id INT, fecha DATETIME) RETURNS DECIMAL(10, 2)
      BEGIN
        DECLARE total DECIMAL(10, 2) DEFAULT 0;
        SELECT SUM(saldo) INTO total
        FROM (
          SELECT id,
            subarticle_id,
            fecha,
            amount AS ingreso,
            @cantidad := IF(-stock < amount, -stock, amount) AS stock,
            unit_cost AS precio,
            @cantidad * unit_cost AS saldo
          FROM (SELECT ne.id, es.subarticle_id, ne.note_entry_date, es.unit_cost, es.amount, @salida := @salida - es.amount AS stock
            FROM (SELECT @salida := total_salidas(subarticle_id, fecha)) salida, note_entries ne
              RIGHT JOIN entry_subarticles es on es.note_entry_id = ne.id
            WHERE (ne.invalidate = 0 OR (ne.invalidate is null and ne.id is null))
              AND es.subarticle_id = subarticle_id
              AND (ne.note_entry_date <= fecha OR (ne.note_entry_date is null and ne.id is null))
            ORDER BY ne.note_entry_date) t1
          WHERE stock < 0) t2;
        RETURN COALESCE(total, 0);
      END
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION total_saldo_bs;
    SQL
    execute <<-SQL
      DROP FUNCTION total_salidas;
    SQL
  end
end
