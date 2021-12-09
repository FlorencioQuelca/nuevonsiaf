SELECT
	s.code AS codigo,
	s.description AS material,
	d.name AS unidad,
	-t.cantidad AS cantidad,
	s.unit AS unidad_medida,
	r.nro_solicitud,
	t.fecha,
	t.detalle,
	t.modelo_id,
	t.subarticle_id AS subarticulo_id,
	(SELECT SUM(tt.cantidad) FROM entradas_salidas tt WHERE tt.fecha <= t.fecha AND tt.subarticle_id = t.subarticle_id) as saldo
FROM subarticles s INNER JOIN entradas_salidas t ON s.id = t.subarticle_id
INNER JOIN requests r ON r.id = t.modelo_id
INNER JOIN users u ON u.id = r.user_id
INNER JOIN departments d ON d.id = u.department_id
WHERE t.tipo = 'salida' AND t.fecha BETWEEN %{desde} AND %{hasta}
ORDER BY s.code, s.description, t.fecha, d.name, r.nro_solicitud
