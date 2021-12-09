class AddProceduresReportes1 < ActiveRecord::Migration
  def up
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
          FROM (SELECT t1.id,
                       t1.subarticle_id,
                       t1.note_entry_date,
                       t1.unit_cost,
                       t1.amount,
                       @salida := @salida - t1.amount AS stock
                  FROM (SELECT ne.id as id,
                               es.subarticle_id as subarticle_id,
                               ne.note_entry_date as note_entry_date,
                               es.unit_cost as unit_cost,
                               es.amount as amount
                          FROM (SELECT @salida := total_salidas(subarticle_id, fecha)) salida, note_entries ne
                                       RIGHT JOIN entry_subarticles es on es.note_entry_id = ne.id
                                 WHERE (ne.invalidate = 0 OR (ne.invalidate is null and ne.id is null))
                                   AND es.subarticle_id = subarticle_id
                                   AND (ne.note_entry_date <= fecha OR (ne.note_entry_date is null and ne.id is null))
                              ORDER BY ne.note_entry_date) t1) t2
          WHERE stock < 0) t3;
        RETURN COALESCE(total, 0);
      END
    SQL
  end

  def down
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
end
