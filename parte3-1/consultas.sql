-- 1. Muestre el nombre y precio de todos los productos con un precio mayor a 500, ordenados alfabéticamente por nombre.
--/*
SELECT nombre_producto, precio
FROM productos
WHERE precio > 500
ORDER BY nombre_producto ASC; 
--*/

-- 2. Inserte un nuevo empleado en la tabla "empleados" con los siguientes datos: 
--            ID 6, nombre "Elena", apellido "López", fecha de contratación "2023-05-01", salario 33000.00, departamento 3.

INSERT INTO empleados VALUES (6, 'Elena', 'López', '2023-05-01', 33000.00, 3);

-- 3. Actualice el salario del empleado con ID 2 a 37000.00.
--/*
UPDATE empleados
SET salario = 37000.00
WHERE id_empleado = 2;
--*/

-- 4. Calcule el promedio de salarios por departamento.
--/*
SELECT d.nombre_departamento, COALESCE(AVG(e.salario), 0) AS promedio_salario
FROM departamentos d
LEFT JOIN empleados e ON d.id_departamento = e.id_departamento
GROUP BY d.nombre_departamento;
--*/

-- 5. Encuentre el total de ventas (suma de totales de pedidos) por cliente, mostrando el nombre y apellido del cliente.
--/*
SELECT c.nombre, c.apellido, SUM(p.total) AS total_ventas
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.nombre, c.apellido;
--*/

-- 6. Encuentra la cantidad de empleados contratados por año-mes y que fueron contratados en el año 2019 o después.
-- Forma1
/*
SELECT DATE_TRUNC('month', fecha_contratacion) AS anio_mes, COUNT(*) AS cantidad_empleados
FROM empleados
WHERE fecha_contratacion >= '2019-01-01'
GROUP BY anio_mes
ORDER BY anio_mes;
--*/
-- Forma 2
--/*
SELECT TO_CHAR(DATE_TRUNC('month', fecha_contratacion), 'YYYY-MM') AS anio_mes, COUNT(*) AS cantidad_empleados
FROM empleados
WHERE fecha_contratacion >= '2019-01-01'
GROUP BY anio_mes
ORDER BY anio_mes;
--*/

--7. Cree una vista que muestre el nombre del producto, la cantidad de veces que ha sido pedido,
--   la fecha del último pedido para cada producto y el total de ingresos generados por ese producto.
--/*
CREATE VIEW vista_productos_pedidos AS
SELECT p.nombre_producto, 
       SUM(dp.cantidad) AS cantidad_veces_pedido,  -- Sumar la cantidad total de veces que se pidió el producto
       MAX(pe.fecha_pedido) AS fecha_ultimo_pedido,
       SUM(dp.cantidad * dp.precio_unitario) AS total_ingresos
FROM productos p
JOIN detalle_pedidos dp ON p.id_producto = dp.id_producto
JOIN pedidos pe ON dp.id_pedido = pe.id_pedido
GROUP BY p.nombre_producto;

SELECT * FROM vista_productos_pedidos;
--*/

-- 8. Escriba una consulta que muestre los departamentos que tienen más de 2 empleados, junto con el número de empleados en cada uno.
--/*
SELECT d.nombre_departamento, COUNT(e.id_empleado) AS numero_empleados
FROM departamentos d
JOIN empleados e ON d.id_departamento = e.id_departamento
GROUP BY d.nombre_departamento
HAVING COUNT(e.id_empleado) > 2;
--*/

-- 9. Encuentre el cliente que ha realizado el pedido de mayor valor y muestre su nombre, el valor del pedido y la fecha.
--/*
SELECT c.nombre, c.apellido, p.total AS valor_pedido, p.fecha_pedido
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
ORDER BY p.total DESC
LIMIT 1;
--*/

-- 10. Cree una función que calcule el total de salarios pagados por departamento en un año específico.
--/*
CREATE OR REPLACE FUNCTION total_salarios_por_departamento(anio INTEGER)
RETURNS TABLE (
    nombre_departamento VARCHAR,
    total_salarios DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.nombre_departamento, 
           COALESCE(SUM(
               CASE
                   -- Si el empleado fue contratado antes del año, contamos todo el año (12 meses)
                   WHEN EXTRACT(YEAR FROM e.fecha_contratacion) < anio THEN e.salario * 12
                   
                   -- Si el empleado fue contratado durante el año, calculamos los meses trabajados en ese año
                   WHEN EXTRACT(YEAR FROM e.fecha_contratacion) = anio THEN e.salario * (13 - EXTRACT(MONTH FROM e.fecha_contratacion))
                   
                   ELSE 0
               END
           ), 0) AS total_salarios
    FROM departamentos d
    LEFT JOIN empleados e ON d.id_departamento = e.id_departamento
    GROUP BY d.nombre_departamento;
END;
$$ LANGUAGE plpgsql;
--*/
SELECT * FROM total_salarios_por_departamento(2021);

-- 11. Implemente un trigger que actualice automáticamente el stock de un producto cuando se realiza un nuevo pedido.
--Crear Funcion que reste el stock
--/*
CREATE OR REPLACE FUNCTION actualizar_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Restar la cantidad del producto pedido al stock disponible
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    -- Devolver la nueva fila de detalle_pedido (esto es obligatorio en funciones de trigger)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
--*/
-- Crear el trigger
--/*
CREATE TRIGGER actualizar_stock_trigger
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock();
--*/
--Probar con un pedido
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario)
VALUES (9, 5, 1, 2, 1200.00);  -- Pedido de 2 laptops
--Verificar si se actualizo
--/*
SELECT nombre_producto, stock
FROM productos
WHERE id_producto = 1;  -- Verificar el stock de laptops
--*/

-- 12. Consulta optimizada. Ahora no tiene que hacer el calculo en cada consulta
--/*
WITH salario_promedio AS (
    SELECT AVG(salario) AS promedio FROM empleados
)
SELECT * 
FROM empleados
WHERE salario > (SELECT promedio FROM salario_promedio);
--*/

-- 14. Escriba una consulta que utilice una ventana deslizante (window function) para calcular el salario acumulado por departamento.
--/*
SELECT e.id_departamento,
       d.nombre_departamento,
       e.nombre,
       e.salario,
       SUM(e.salario) OVER (PARTITION BY e.id_departamento ORDER BY e.salario ASC, e.id_empleado) AS salario_acumulado
FROM empleados e
JOIN departamentos d ON e.id_departamento = d.id_departamento
ORDER BY e.id_departamento, e.salario;
--*/
-- 15. Los errores son:
--                      -No se puede usar un alias de agregación (total_pedidos) en WHERE; para eso se usa HAVING.
--                      -La tabla clientes no tiene información de los pedidos, por lo que se necesita un JOIN con 
--                       la tabla pedidos para contar cuántos pedidos hizo cada cliente.
--/*
SELECT c.nombre, COUNT(p.id_pedido) AS total_pedidos
FROM clientes c
JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.nombre
HAVING COUNT(p.id_pedido) > 2;
--*/

-- 16. Diseñe una consulta para encontrar posibles duplicados en la tabla "clientes" basándose en nombre y apellido.
--/*
SELECT nombre, apellido, COUNT(*) AS total_duplicados
FROM clientes
GROUP BY nombre, apellido
HAVING COUNT(*) > 1;
--*/

