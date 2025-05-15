-- Crear base de datos
CREATE DATABASE dannys_diner;
USE dannys_diner;

-- Crear tabla sales
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

-- Insertar datos en sales
INSERT INTO sales (customer_id, order_date, product_id) VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Crear tabla menu
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(10),
  price INT
);

-- Insertar datos en menu
INSERT INTO menu (product_id, product_name, price) VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Crear tabla members
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

-- Insertar datos en members
INSERT INTO members (customer_id, join_date) VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  /*Consulta 1*/
SELECT 
  sales.customer_id,
  SUM(menu.price) AS total_spent
FROM 
  sales
JOIN 
  menu ON sales.product_id = menu.product_id
GROUP BY 
  sales.customer_id;

/*Consulta 2*/
SELECT 
  sales.customer_id,
  /*disctinc es para contar un sola vez */
  COUNT( DISTINCT sales.order_date) AS visit_days 
FROM 
  sales
GROUP BY 
  sales.customer_id;

/*Consulta 3*/
SELECT 
  sales.customer_id,
  menu.product_name
FROM 
  sales
JOIN 
  (
    SELECT 
      customer_id, 
      MIN(order_date) AS first_date
    FROM 
      sales
    GROUP BY 
      customer_id
  ) AS first_orders
  ON sales.customer_id = first_orders.customer_id 
  AND sales.order_date = first_orders.first_date
JOIN 
  menu ON sales.product_id = menu.product_id;

/*Consulta 4*/

SELECT 
  menu.product_name,
  COUNT(sales.product_id) AS total_purchases
FROM 
  sales
JOIN 
  menu ON sales.product_id = menu.product_id
GROUP BY 
  sales.product_id, menu.product_name
ORDER BY 
  total_purchases DESC;
/* consulta 5 */
SELECT 
  customer_id,
  product_name,
  COUNT(*) AS veces_comprado
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name;
SELECT 
  customer_id,
  product_name,
  veces_comprado
FROM (
  SELECT 
    customer_id,
    product_name,
    COUNT(*) AS veces_comprado,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS ranking
  FROM sales
  JOIN menu ON sales.product_id = menu.product_id
  GROUP BY customer_id, product_name
) AS conteo
WHERE ranking = 1;
/*Consulta 6*/
SELECT 
  members.customer_id,
  menu.product_name AS primer_producto_como_miembro,
  sales.order_date AS fecha_compra
FROM 
  members
JOIN 
  sales ON members.customer_id = sales.customer_id 
  AND sales.order_date >= members.join_date
JOIN 
  menu ON sales.product_id = menu.product_id
WHERE 
  sales.order_date = (
    SELECT MIN(sales.order_date)
    FROM sales
    WHERE sales.customer_id = members.customer_id 
    AND sales.order_date >= members.join_date
  )
ORDER BY 
  members.customer_id;
  /*Consulta 7*/
  SELECT 
  members.customer_id,
  menu.product_name AS ultimo_producto_antes_de_membresia,
  sales.order_date AS fecha_compra
FROM 
  members
JOIN 
  sales ON members.customer_id = sales.customer_id 
  AND sales.order_date < members.join_date
JOIN 
  menu ON sales.product_id = menu.product_id
WHERE 
  sales.order_date = (
    SELECT MAX(sales.order_date)
    FROM sales
    WHERE sales.customer_id = members.customer_id 
    AND sales.order_date < members.join_date
  )
ORDER BY 
  members.customer_id;
  /*Consulta 8*/
  SELECT 
  m.customer_id,
  COUNT(*) AS total_articulos,
  SUM(me.price) AS monto_total_gastado
FROM 
  members m
JOIN 
  sales s ON m.customer_id = s.customer_id AND s.order_date < m.join_date
JOIN 
  menu me ON s.product_id = me.product_id
GROUP BY 
  m.customer_id
ORDER BY 
  m.customer_id;
    /*Consulta 9*/
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
      ELSE m.price * 10
    END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;
  /*Consulta 10*/
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN s.order_date BETWEEN mbr.join_date AND DATE_ADD(mbr.join_date, INTERVAL 6 DAY)
        THEN me.price * 10 * 2  -- semana doble para todos los productos
      WHEN me.product_name = 'sushi'
        THEN me.price * 10 * 2  -- sushi fuera de la semana
      ELSE me.price * 10       -- resto fuera de la semana
    END
  ) AS puntos_hasta_enero
FROM sales s
JOIN menu me ON s.product_id = me.product_id
JOIN members mbr ON s.customer_id = mbr.customer_id
WHERE s.order_date <= '2021-01-31'
  AND s.customer_id IN ('A', 'B')
GROUP BY s.customer_id;