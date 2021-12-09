class AddProcedimientosAlmacenadosKardexV2< ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE PROCEDURE obtiene_saldos_iniciales_v2(IN identificador INT, IN fecha_inicio VARCHAR(255), IN random_name VARCHAR(255))
      BEGIN
        DECLARE entrada_id INT;
        DECLARE entrada_cantidad DECIMAL(10,2);
        DECLARE cantidad_entradas DECIMAL(10,2);
        DECLARE saldo_salidas DECIMAL(10,2);

        # Obtiene las entradas antes de la fecha de inicio
        EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE entradas_saldos_', random_name,'_temp 
                                    SELECT id, fecha, tipo, cantidad, costo_unitario
                                      FROM entradas_salidas es
                                     WHERE subarticle_id = ?
                                       AND tipo = ?
                                       AND cantidad != 0
                                       AND fecha < cast(?  as datetime)
                                  ORDER BY fecha ASC, tipo ASC, id ASC;') USING identificador, 'entrada', fecha_inicio;
      
        EXECUTE IMMEDIATE concat('SELECT COUNT(*) INTO @cantidad_entradas FROM entradas_saldos_', random_name,'_temp;');
        SELECT -1 * sum(cantidad)
          INTO saldo_salidas
          FROM entradas_salidas es
         WHERE subarticle_id = identificador
           AND tipo = 'salida'
           AND fecha < cast(fecha_inicio  as datetime)
         ORDER BY fecha ASC, tipo ASC, id ASC;
        WHILE @cantidad_entradas > 0 AND saldo_salidas > 0 DO
          EXECUTE IMMEDIATE concat('SELECT id,
                                           cantidad
                                      INTO @entrada_id,
                                           @entrada_cantidad
                                      FROM entradas_saldos_', random_name,'_temp LIMIT 1;');
          IF (saldo_salidas - @entrada_cantidad) >= 0  THEN
            EXECUTE IMMEDIATE concat('UPDATE entradas_saldos_', random_name,'_temp set cantidad = 0 where id = ?;') USING @entrada_id;
            SET saldo_salidas = saldo_salidas - @entrada_cantidad;
          ELSE
            EXECUTE IMMEDIATE concat('UPDATE entradas_saldos_', random_name,'_temp set cantidad = (? - ?) where id = ?;') USING @entrada_cantidad, saldo_salidas, @entrada_id;
            SET saldo_salidas =  0;
          END IF;
          EXECUTE IMMEDIATE concat('DELETE FROM entradas_saldos_', random_name,'_temp WHERE cantidad = 0;');
          SET @cantidad_entradas = @cantidad_entradas - 1;
        END WHILE;
        IF saldo_salidas > 0 THEN
          # Adicionarlo como salida en el cursor de entradas y salidas
          EXECUTE IMMEDIATE concat('INSERT INTO entradas_salidas_saldos_', random_name,'_temp (fecha, tipo, detalle, cantidad) VALUES (?, ?, ?, ?);') USING cast(fecha_inicio as datetime), 'salida', 'SALDO INICIAL', -1 * saldo_salidas;
        END IF;
        EXECUTE IMMEDIATE concat('SELECT COUNT(*) INTO @cantidad_entradas FROM entradas_saldos_', random_name,'_temp;');
        IF @cantidad_entradas > 0 THEN
          EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE kardex_', random_name, '_temp (nro INT(11), id INT(11), factura VARCHAR(255), nro_pedido VARCHAR(255), cite_ems_plantillas VARCHAR(255), fecha DATE, tipo VARCHAR(255), detalle VARCHAR(255), cantidad DECIMAL(10,2), costo_unitario DECIMAL(10,2));');
          # Adicionarlo como salida en el cursor de entradas y salidas
          EXECUTE IMMEDIATE concat('INSERT INTO kardex_', random_name, '_temp (nro, id, fecha, tipo, detalle, cantidad, costo_unitario)
                                    SELECT ROW_NUMBER() OVER W AS nro,
                                           id,
                                           ?,
                                           tipo,
                                           ?,
                                           cantidad,
                                           costo_unitario 
                                      FROM entradas_saldos_', random_name, '_temp
                               WINDOW W AS (ORDER BY fecha ASC, tipo ASC, id ASC);') USING CAST(fecha_inicio as DATE),'SALDO INICIAL';
        END IF;
      END;
    SQL
    execute <<-SQL
      CREATE OR REPLACE PROCEDURE genera_kardex_v2(identificador INT, fecha_inicio VARCHAR(255), fecha_fin VARCHAR(255))
      BEGIN
        DECLARE row_id INT;
        DECLARE row_fecha DATE;
        DECLARE row_tipo VARCHAR(255);
        DECLARE row_detalle VARCHAR(255);
        DECLARE row_cantidad DECIMAL(10,2);
        DECLARE row_costo_unitario DECIMAL(10,2);
        DECLARE row_factura VARCHAR(255);
        DECLARE row_nro_pedido VARCHAR(255);        
        DECLARE row_cite_ems_plantillas VARCHAR(255);
        DECLARE tipo_entrada VARCHAR(10) DEFAULT 'entrada';
        DECLARE entrada_id INT;
        DECLARE entrada_cantidad DECIMAL(10,2);
        DECLARE entrada_costo_unitario DECIMAL(10,2);
        DECLARE indice INT;
        DECLARE saldo_compensar DECIMAL(10,2);
        DECLARE random_name VARCHAR(255) default ROUND(RAND() * 1000000);
        DECLARE cantidad_entradas DECIMAL(10,2);
        DECLARE saldo_salidas DECIMAL(10,2);
        DECLARE n INT DEFAULT 0;
        DECLARE i INT DEFAULT 0;

        EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE kardex_', random_name, '_temp (nro INT(11), id INT(11), factura VARCHAR(255), nro_pedido VARCHAR(255), cite_ems_plantillas VARCHAR(255), fecha DATE, tipo VARCHAR(255), detalle VARCHAR(255), cantidad DECIMAL(10,2), costo_unitario DECIMAL(10,2));');
        EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE entradas_salidas_saldos_', random_name,'_temp (id INT(11), factura VARCHAR(255), nro_pedido VARCHAR(255), cite_ems_plantillas VARCHAR(255), fecha DATE, tipo VARCHAR(255), detalle VARCHAR(255), cantidad INT(11), costo_unitario DECIMAL(10,2));');
        CALL obtiene_saldos_iniciales_v2(identificador, fecha_inicio, random_name);
        EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE entradas_salidas_', random_name, '_temp
                                    SELECT id,
                                           factura,
                                           nro_pedido,
                                           cite_ems_plantillas,
                                           fecha,
                                           tipo,
                                           detalle,
                                           cantidad,
                                           costo_unitario
                                      FROM entradas_salidas_saldos_', random_name, '_temp 
                                 UNION ALL 
                                    SELECT es.id,
                                           es.factura,
                                           es.nro_pedido,
                                           es.cite_ems_plantillas,
                                           es.fecha,
                                           es.tipo,
                                           es.detalle,
                                           es.cantidad,
                                           es.costo_unitario
                                      FROM entradas_salidas es
                                     WHERE subarticle_id = ? 
                                       AND fecha BETWEEN cast(? as datetime) AND cast(? as datetime)
                                  ORDER BY fecha ASC, tipo ASC, id ASC;') USING identificador, fecha_inicio, fecha_fin; 

        EXECUTE IMMEDIATE concat('CREATE OR REPLACE TEMPORARY TABLE entradas_', random_name,'_temp 
                                    SELECT *
                                      FROM entradas_saldos_', random_name,'_temp 
                                 UNION ALL 
                                    SELECT id, fecha, tipo, cantidad, costo_unitario
                                      FROM entradas_salidas es
                                     WHERE subarticle_id = ? 
                                       AND tipo = ?
                                       AND cantidad > 0
                                       AND fecha BETWEEN cast(? as datetime) AND cast(? as datetime)
                                  ORDER BY fecha ASC, tipo ASC, id ASC;') USING identificador,'entrada', fecha_inicio, fecha_fin;
      
        EXECUTE IMMEDIATE concat('SELECT COUNT(*) FROM entradas_salidas_', random_name, '_temp INTO @n;');
        EXECUTE IMMEDIATE concat('SELECT COUNT(*) FROM kardex_', random_name, '_temp INTO @indice;');
        SET i=0;
        WHILE i < @n DO
          EXECUTE IMMEDIATE concat('SELECT id, factura, nro_pedido, cite_ems_plantillas, fecha, tipo, detalle, cantidad, costo_unitario INTO @row_id, @row_factura, @row_nro_pedido, @row_cite_ems_plantillas, @row_fecha, @row_tipo, @row_detalle, @row_cantidad, @row_costo_unitario FROM entradas_salidas_', random_name, '_temp LIMIT ?,1;') USING i;
      
          IF @row_tipo = 'entrada' THEN
            SET @indice = @indice + 1;
            EXECUTE IMMEDIATE concat('INSERT INTO kardex_', random_name, '_temp (nro, id, factura, nro_pedido, cite_ems_plantillas, fecha, tipo, detalle, cantidad, costo_unitario) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);') USING @indice, @row_id, @row_factura, @row_nro_pedido, @row_cite_ems_plantillas, @row_fecha, @row_tipo, @row_detalle, @row_cantidad, @row_costo_unitario;
          ELSE
            SET @row_cantidad = -1 * @row_cantidad;
            label1: REPEAT
              EXECUTE IMMEDIATE concat('DELETE FROM entradas_', random_name,'_temp WHERE cantidad = 0;');
              EXECUTE IMMEDIATE concat('SELECT id,
                                               costo_unitario,
                                               cantidad
                                          INTO @entrada_id,
                                               @entrada_costo_unitario,
                                               @entrada_cantidad
                                          FROM entradas_', random_name,'_temp LIMIT 1;'); 
              SET @indice = @indice + 1;
              IF (@entrada_cantidad - @row_cantidad) >= 0 THEN
                SET saldo_compensar = 0;
                EXECUTE IMMEDIATE concat('UPDATE entradas_', random_name,'_temp set cantidad = (',@entrada_cantidad - @row_cantidad,') where id = ',@entrada_id,';');
                EXECUTE IMMEDIATE concat('INSERT INTO kardex_', random_name, '_temp(nro, id, factura, nro_pedido, cite_ems_plantillas, fecha, tipo, detalle, cantidad, costo_unitario) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);') USING @indice, @row_id, @row_factura, @row_nro_pedido, @row_cite_ems_plantillas, @row_fecha, @row_tipo, @row_detalle, -1*@row_cantidad, @entrada_costo_unitario;              
              ELSE
                SET saldo_compensar = @row_cantidad - @entrada_cantidad;
                EXECUTE IMMEDIATE concat('UPDATE entradas_', random_name,'_temp set cantidad = 0 where id = ',@entrada_id,';');
                EXECUTE IMMEDIATE concat('INSERT INTO kardex_', random_name, '_temp(nro, id, factura, nro_pedido, cite_ems_plantillas, fecha, tipo, detalle, cantidad, costo_unitario) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);') USING @indice, @row_id, @row_factura, @row_nro_pedido, @row_cite_ems_plantillas, @row_fecha, @row_tipo, @row_detalle, -1*@entrada_cantidad, @entrada_costo_unitario;
                SET @row_cantidad = saldo_compensar;
              END IF;
            UNTIL saldo_compensar = 0
            END REPEAT label1;
          END IF;
          SET i = i + 1;
        END WHILE;

        EXECUTE IMMEDIATE concat('SELECT nro,
                                         id,
                                         factura,
                                         nro_pedido, 
                                         cite_ems_plantillas,
                                         fecha,
                                         tipo,
                                         detalle,
                                         costo_unitario,
                                         IF(cantidad >= 0, cantidad, 0)AS cantidad_ingreso,
                                         IF(cantidad < 0, cantidad*-1,0)AS cantidad_egreso,
                                         SUM(cantidad) OVER(ORDER BY NRO ASC)AS cantidad_saldo,
                                         IF(cantidad >= 0, cantidad*costo_unitario, 0) AS importe_ingreso,
                                         IF(cantidad < 0, cantidad*-1*costo_unitario,0) AS importe_egreso,
                                         SUM(cantidad*costo_unitario) OVER(ORDER BY NRO ASC)AS importe_saldo
                                    FROM kardex_', random_name, '_temp ORDER BY nro;');
        
        EXECUTE IMMEDIATE concat('DROP TEMPORARY TABLE ', 'kardex_', random_name, '_temp;'); 
        EXECUTE IMMEDIATE concat('DROP TEMPORARY TABLE ', 'entradas_', random_name, '_temp;');
        EXECUTE IMMEDIATE concat('DROP TEMPORARY TABLE ', 'entradas_saldos_', random_name, '_temp;');
        EXECUTE IMMEDIATE concat('DROP TEMPORARY TABLE ', 'entradas_salidas_', random_name, '_temp;');
        EXECUTE IMMEDIATE concat('DROP TEMPORARY TABLE ', 'entradas_salidas_saldos_', random_name, '_temp;');
      END;
    SQL
  end

  def down
    execute <<-SQL
      DROP PROCEDURE genera_kardex_v2;
    SQL

    execute <<-SQL
      DROP PROCEDURE obtiene_saldos_iniciales_v2;
    SQL
  end
end
