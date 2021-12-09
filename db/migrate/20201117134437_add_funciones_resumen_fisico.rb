class AddFuncionesResumenFisico < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION total_ingresos_v1(subarticle_id INT, fecha_inicio DATETIME, fecha_fin DATETIME) RETURNS VARCHAR(255)
      BEGIN
        DECLARE total DECIMAL(10, 2);
        DECLARE cantidad DECIMAL(10, 2);
        select IFNULL(sum(t2.total), 0), IFNULL(sum(t2.amount), 0) into total, cantidad
          from (select t1.subarticle_id,
                       t1.note_entry_id,
                       t1.entry_subarticle_id,
                       t1.entry_date,
                       t1.unit_cost,
                       t1.amount,
                       (t1.unit_cost * t1.amount) as total
                  from (SELECT es.subarticle_id as subarticle_id,
                               ne.id as note_entry_id,
                               es.id as entry_subarticle_id,
                               IFNULL(ne.note_entry_date, es.date) as entry_date,
                               es.unit_cost as unit_cost,
                               es.amount as amount
                          FROM note_entries ne RIGHT JOIN entry_subarticles es on es.note_entry_id = ne.id
                         WHERE (ne.invalidate = 0 OR (ne.invalidate is null and ne.id is null))
                           AND es.subarticle_id = subarticle_id
                           AND es.invalidate = 0
                      ORDER BY entry_date, note_entry_id, entry_subarticle_id) t1 
                 where t1.entry_date <= fecha_fin
                   and t1.entry_date > fecha_inicio) t2;
        return CONCAT(cantidad, '|', total);
      END;
    SQL

    execute <<-SQL
    CREATE OR REPLACE FUNCTION saldo_final_v1(subarticle_id INT, fecha_fin DATETIME) RETURNS VARCHAR(255)
    BEGIN
      DECLARE total DECIMAL(10, 2);
      DECLARE cantidad DECIMAL(10, 2);
      SELECT IFNULL(sum(stock), 0), IFNULL(SUM(saldo), 0) into cantidad, total
        FROM (SELECT @cantidad := IF(-stock < amount, -stock, amount) AS stock,
                     @cantidad * unit_cost AS saldo
                FROM (SELECT t1.note_entry_id,
                             t1.subarticle_id,
                             t1.entry_subarticle_id,
                             t1.entry_date,
                             t1.unit_cost,
                             t1.amount,
                             @salida := @salida - t1.amount AS stock
                        FROM (SELECT es.subarticle_id as subarticle_id,
                                     ne.id as note_entry_id,
                                     es.id as entry_subarticle_id,
                                     IFNULL(ne.note_entry_date, es.date) as entry_date,
                                     es.unit_cost as unit_cost,
                                     es.amount as amount
                                FROM (SELECT @salida := total_salidas(subarticle_id, fecha_fin)) salida, note_entries ne RIGHT JOIN entry_subarticles es on es.note_entry_id = ne.id
                                       WHERE (ne.invalidate = 0 OR (ne.invalidate is null and ne.id is null))
                                         AND es.subarticle_id = subarticle_id
                                         AND es.invalidate = 0
                                    ORDER BY entry_date, note_entry_id, entry_subarticle_id) t1
                       WHERE t1.entry_date <= fecha_fin) t2
               WHERE stock < 0) t3;
      return CONCAT(cantidad, '|', total);
    END;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION total_ingresos_v1;
    SQL

    execute <<-SQL
      DROP FUNCTION saldo_final_v1;
    SQL
  end
end
