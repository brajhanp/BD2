CREATE DATABASE IF NOT EXISTS pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

/*consulta 1:*/
SELECT COUNT(*) AS total_pizzas_ordered
FROM customer_orders;

/*consulta 2:*/
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;

/*consulta 3:*/
SELECT 
    runner_id,
    COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id;

/*consulta 4:*/
SELECT 
    p.pizza_name,
    COUNT(c.pizza_id) AS delivered_count
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
JOIN pizza_names p ON c.pizza_id = p.pizza_id
WHERE r.cancellation IS NULL OR r.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY p.pizza_name;

/*consulta 5:*/
SELECT 
    c.customer_id,
    p.pizza_name,
    COUNT(c.pizza_id) AS order_count
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

/*consulta 6:*/
SELECT 
    c.order_id,
    COUNT(c.pizza_id) AS pizza_count
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL OR r.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY c.order_id
ORDER BY pizza_count DESC
LIMIT 1;

/*consulta 7:*/
SELECT 
    c.customer_id,
    SUM(CASE WHEN c.exclusions <> '' AND c.exclusions <> 'null' OR c.extras <> '' AND c.extras <> 'null' THEN 1 ELSE 0 END) AS with_changes,
    SUM(CASE WHEN (c.exclusions = '' OR c.exclusions = 'null' OR c.exclusions IS NULL) 
              AND (c.extras = '' OR c.extras = 'null' OR c.extras IS NULL) THEN 1 ELSE 0 END) AS no_changes
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL OR r.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY c.customer_id;

/*consulta 8:*/
SELECT 
    COUNT(*) AS pizzas_with_both
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE (r.cancellation IS NULL OR r.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation'))
  AND (c.exclusions <> '' AND c.exclusions <> 'null' AND c.exclusions IS NOT NULL)
  AND (c.extras <> '' AND c.extras <> 'null' AND c.extras IS NOT NULL);

/*consulta 9:*/
SELECT 
    HOUR(order_time) AS hour_of_day,
    COUNT(*) AS pizzas_ordered
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

/*consulta 10:*/
SELECT 
    DAYNAME(order_time) AS day_of_week,
    COUNT(*) AS pizzas_ordered
FROM customer_orders
GROUP BY day_of_week, DAYOFWEEK(order_time)
ORDER BY DAYOFWEEK(order_time);

/*consulta 11:*/
SELECT 
  WEEK(registration_date, 1) - WEEK('2021-01-01', 1) + 1 AS semana,
  COUNT(*) AS repartidores_registrados
FROM runners
GROUP BY semana
ORDER BY semana;

/*consulta 12:*/
SELECT 
  runner_id,
  AVG(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS tiempo_promedio_minutos
FROM runner_orders
WHERE (cancellation IS NULL OR cancellation = '' OR LOWER(cancellation) = 'null')
  AND duration IS NOT NULL
GROUP BY runner_id;

/*consulta 13:*/
SELECT 
  pizzas_por_orden.order_id,
  pizzas_por_orden.cantidad_pizzas,
  CAST(SUBSTRING_INDEX(runner_orders.duration, ' ', 1) AS UNSIGNED) AS duracion_minutos
FROM (
  SELECT 
    order_id,
    COUNT(pizza_id) AS cantidad_pizzas
  FROM customer_orders
  GROUP BY order_id
) AS pizzas_por_orden
JOIN runner_orders ON pizzas_por_orden.order_id = runner_orders.order_id
WHERE runner_orders.cancellation IS NULL OR runner_orders.cancellation = '' OR LOWER(runner_orders.cancellation) = 'null';

/*consulta 14:*/
SELECT 
  customer_orders.customer_id,
  AVG(CAST(REPLACE(runner_orders.distance, 'km', '') AS DECIMAL(5,2))) AS distancia_promedio_km
FROM customer_orders
JOIN runner_orders ON customer_orders.order_id = runner_orders.order_id
WHERE (runner_orders.cancellation IS NULL OR runner_orders.cancellation = '' OR LOWER(runner_orders.cancellation) = 'null')
GROUP BY customer_orders.customer_id;

/*consulta 15:*/
SELECT 
  MAX(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) -
  MIN(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) AS diferencia_minutos
FROM runner_orders
WHERE (cancellation IS NULL OR cancellation = '' OR LOWER(cancellation) = 'null');

/*consulta 16:*/
SELECT 
  order_id,
  runner_id,
  ROUND(
    CAST(REPLACE(REPLACE(distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) /
    (CAST(SUBSTRING_INDEX(duration, ' ', 1) AS DECIMAL(5,2)) / 60), 2
  ) AS velocidad_kmh
FROM runner_orders
WHERE (cancellation IS NULL OR cancellation = '' OR LOWER(cancellation) = 'null')
  AND distance IS NOT NULL AND duration IS NOT NULL;

/*consulta 17:*/
SELECT 
  runner_id,
  COUNT(*) AS total_entregas,
  SUM(CASE 
      WHEN cancellation IS NULL OR cancellation = '' OR LOWER(cancellation) = 'null' THEN 1
      ELSE 0
  END) AS entregas_exitosas,
  ROUND(100 * SUM(CASE 
      WHEN cancellation IS NULL OR cancellation = '' OR LOWER(cancellation) = 'null' THEN 1
      ELSE 0
  END) / COUNT(*), 2) AS porcentaje_exito
FROM runner_orders
GROUP BY runner_id;

/*consulta 18:*/
SELECT 
  nombres.pizza,
  GROUP_CONCAT(toppings.topping_name ORDER BY toppings.topping_id) AS ingredientes_estandar
FROM (
  SELECT 
    pizza_recipes.pizza_id,
    pizza_names.pizza_name AS pizza,
    pizza_recipes.toppings
  FROM pizza_recipes
  JOIN pizza_names ON pizza_recipes.pizza_id = pizza_names.pizza_id
) AS nombres
JOIN pizza_toppings AS toppings 
  ON FIND_IN_SET(toppings.topping_id, nombres.toppings)
GROUP BY nombres.pizza_id, nombres.pizza;

/*consulta 19:*/
WITH RECURSIVE numeros AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numeros WHERE n < 5
),
extras_separados AS (
  SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1)) AS topping_id
  FROM customer_orders
  JOIN numeros ON n <= 1 + LENGTH(extras) - LENGTH(REPLACE(extras, ',', ''))
  WHERE extras IS NOT NULL AND extras != '' AND LOWER(extras) != 'null'
)
SELECT 
  pizza_toppings.topping_name AS extra,
  COUNT(*) AS veces_agregado
FROM extras_separados
JOIN pizza_toppings ON pizza_toppings.topping_id = extras_separados.topping_id
GROUP BY pizza_toppings.topping_name
ORDER BY veces_agregado DESC
LIMIT 1;

/*consulta 20:*/
WITH RECURSIVE numeros AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM numeros WHERE n < 5
),
exclusiones_separadas AS (
  SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1)) AS topping_id
  FROM customer_orders
  JOIN numeros ON n <= 1 + LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', ''))
  WHERE exclusions IS NOT NULL AND exclusions != '' AND LOWER(exclusions) != 'null'
)
SELECT 
  pizza_toppings.topping_name AS exclusion,
  COUNT(*) AS veces_excluido
FROM exclusiones_separadas
JOIN pizza_toppings ON pizza_toppings.topping_id = exclusiones_separadas.topping_id
GROUP BY pizza_toppings.topping_name
ORDER BY veces_excluido DESC
LIMIT 1;
/*Consulta 21*/
SELECT 
    order_id,
    customer_id,
    CASE 
        WHEN pizza_id = 1 THEN 'Meat Lovers'
        ELSE 'Vegetarian'
    END AS pizza_type,
    CONCAT(
        CASE 
            WHEN pizza_id = 1 THEN 'Meat Lovers'
            ELSE 'Vegetarian'
        END,
        CASE 
            WHEN exclusions IS NULL OR exclusions = '' OR exclusions = 'null' THEN ''
            ELSE CONCAT(' - Exclude ', 
                REPLACE(
                    REPLACE(
                        (SELECT GROUP_CONCAT(topping_name ORDER BY topping_name SEPARATOR ', ') 
                         FROM pizza_toppings 
                         WHERE FIND_IN_SET(topping_id, 
                             REPLACE(REPLACE(REPLACE(c.exclusions, ' ', ''), 'null', ''))), 
                    ',', ', '
                ), '')
        END,
        CASE 
            WHEN extras IS NULL OR extras = '' OR extras = 'null' THEN ''
            ELSE CONCAT(' - Extra ', 
                REPLACE(
                    REPLACE(
                        (SELECT GROUP_CONCAT(topping_name ORDER BY topping_name SEPARATOR ', ') 
                         FROM pizza_toppings 
                         WHERE FIND_IN_SET(topping_id, 
                             REPLACE(REPLACE(REPLACE(c.extras, ' ', ''), 'null', '')))), 
                    ',', ', '
                ), '')
        END
    ) AS order_item
FROM customer_orders c;
/*Consulta 22*/
WITH pizza_base AS (
    SELECT 
        c.order_id,
        c.customer_id,
        c.pizza_id,
        p.pizza_name,
        CASE 
            WHEN c.exclusions IS NULL OR c.exclusions = '' OR c.exclusions = 'null' THEN ''
            ELSE REPLACE(REPLACE(c.exclusions, ' ', ''), 'null', '')
        END AS exclusions,
        CASE 
            WHEN c.extras IS NULL OR c.extras = '' OR c.extras = 'null' THEN ''
            ELSE REPLACE(REPLACE(c.extras, ' ', ''), 'null', '')
        END AS extras,
        pr.toppings AS base_toppings
    FROM customer_orders c
    JOIN pizza_names p ON c.pizza_id = p.pizza_id
    JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
),
ingredients AS (
    SELECT 
        pb.*,
        pt.topping_id,
        pt.topping_name,
        CASE 
            WHEN FIND_IN_SET(pt.topping_id, pb.exclusions) > 0 THEN 0 -- Excluded
            WHEN FIND_IN_SET(pt.topping_id, pb.extras) > 0 THEN 2 -- Extra (count as 2)
            WHEN FIND_IN_SET(pt.topping_id, pb.base_toppings) > 0 THEN 1 -- Standard
            ELSE 0 -- Not part of this pizza
        END AS topping_count
    FROM pizza_base pb
    JOIN pizza_toppings pt ON 
        FIND_IN_SET(pt.topping_id, pb.base_toppings) > 0 OR
        FIND_IN_SET(pt.topping_id, pb.exclusions) > 0 OR
        FIND_IN_SET(pt.topping_id, pb.extras) > 0
)
SELECT 
    order_id,
    customer_id,
    CONCAT(
        pizza_name, 
        ': ', 
        (SELECT GROUP_CONCAT(
            CASE 
                WHEN topping_count = 2 THEN CONCAT('2x', topping_name)
                ELSE topping_name
            END
            ORDER BY topping_name SEPARATOR ', '
        ) FROM ingredients i2 
        WHERE i2.order_id = i.order_id AND i2.customer_id = i.customer_id AND i2.pizza_id = i.pizza_id
        AND i2.topping_count > 0)
    ) AS ingredient_list
FROM ingredients i
GROUP BY order_id, customer_id, pizza_id, pizza_name;
/*Consulta 23*/
WITH delivered_orders AS (
    SELECT c.*
    FROM customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL OR r.cancellation = '' OR LOWER(r.cancellation) = 'null'
),
pizza_base AS (
    SELECT 
        c.order_id,
        c.pizza_id,
        pr.toppings AS base_toppings,
        CASE 
            WHEN c.exclusions IS NULL OR c.exclusions = '' OR c.exclusions = 'null' THEN ''
            ELSE REPLACE(REPLACE(c.exclusions, ' ', ''), 'null', '')
        END AS exclusions,
        CASE 
            WHEN c.extras IS NULL OR c.extras = '' OR c.extras = 'null' THEN ''
            ELSE REPLACE(REPLACE(c.extras, ' ', ''), 'null', '')
        END AS extras
    FROM delivered_orders c
    JOIN pizza_recipes pr ON c.pizza_id = pr.pizza_id
),
ingredient_counts AS (
    SELECT 
        pt.topping_id,
        pt.topping_name,
        SUM(
            CASE 
                WHEN FIND_IN_SET(pt.topping_id, pb.exclusions) > 0 THEN 0 -- Excluded
                WHEN FIND_IN_SET(pt.topping_id, pb.extras) > 0 THEN 1 -- Extra
                WHEN FIND_IN_SET(pt.topping_id, pb.base_toppings) > 0 THEN 1 -- Standard
                ELSE 0 -- Not part of this pizza
            END
        ) AS total_used
    FROM pizza_base pb
    JOIN pizza_toppings pt ON 
        FIND_IN_SET(pt.topping_id, pb.base_toppings) > 0 OR
        FIND_IN_SET(pt.topping_id, pb.exclusions) > 0 OR
        FIND_IN_SET(pt.topping_id, pb.extras) > 0
    GROUP BY pt.topping_id, pt.topping_name
)
SELECT 
    topping_name,
    total_used
FROM ingredient_counts
ORDER BY total_used DESC;
/*Consulta 24*/
SELECT 
    SUM(CASE 
        WHEN p.pizza_name = 'Meatlovers' THEN 12
        WHEN p.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END) AS total_revenue
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL OR r.cancellation = '' OR LOWER(r.cancellation) = 'null';
/*Consulta 25*/
SELECT 
    SUM(CASE 
        WHEN p.pizza_name = 'Meatlovers' THEN 12
        WHEN p.pizza_name = 'Vegetarian' THEN 10
        ELSE 0
    END) +
    SUM(CASE 
        WHEN c.extras IS NULL OR c.extras = '' OR c.extras = 'null' THEN 0
        ELSE (LENGTH(c.extras) - LENGTH(REPLACE(c.extras, ',', '')) + 1
    END) AS total_revenue_with_extras
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL OR r.cancellation = '' OR LOWER(r.cancellation) = 'null';
/*Consulta 26*/
-- Creación de la tabla de calificaciones
DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings (
  rating_id INTEGER AUTO_INCREMENT PRIMARY KEY,
  order_id INTEGER,
  customer_id INTEGER,
  runner_id INTEGER,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  rating_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  comments TEXT,
  FOREIGN KEY (order_id) REFERENCES runner_orders(order_id),
  FOREIGN KEY (customer_id) REFERENCES customer_orders(customer_id),
  FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);

-- Inserción de datos de ejemplo
INSERT INTO runner_ratings (order_id, customer_id, runner_id, rating, comments)
VALUES
  (1, 101, 1, 4, 'Good service but slightly late'),
  (2, 101, 1, 5, 'Perfect delivery!'),
  (3, 102, 1, 3, 'Pizza was warm but not hot'),
  (4, 103, 2, 4, 'Friendly runner'),
  (5, 104, 3, 5, 'Excellent service'),
  (7, 105, 2, 2, 'Late delivery and cold pizza'),
  (8, 102, 2, 4, 'Good service overall'),
  (10, 104, 1, 5, 'Fast and friendly!');
  /*Consulta 27*/
  SELECT 
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS mins_to_pickup,
    CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS UNSIGNED) AS delivery_duration_mins,
    ROUND(
        CAST(REPLACE(REPLACE(ro.distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) /
        (CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS DECIMAL(5,2)) / 60), 2
    ) AS avg_speed_kmh,
    COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN runner_ratings rr ON co.order_id = rr.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = '' OR LOWER(ro.cancellation) = 'null'
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.distance, ro.duration;
/*Consulta 27*/
SELECT 
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS mins_to_pickup,
    CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS UNSIGNED) AS delivery_duration_mins,
    ROUND(
        CAST(REPLACE(REPLACE(ro.distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) /
        (CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS DECIMAL(5,2)) / 60), 2
    ) AS avg_speed_kmh,
    COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN runner_ratings rr ON co.order_id = rr.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = '' OR LOWER(ro.cancellation) = 'null'
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.distance, ro.duration;
/*Consulta 28*/
SELECT 
    SUM(pizza_revenue) - SUM(runner_payment) AS net_profit
FROM (
    SELECT 
        co.order_id,
        SUM(CASE 
            WHEN p.pizza_name = 'Meatlovers' THEN 12
            WHEN p.pizza_name = 'Vegetarian' THEN 10
            ELSE 0
        END) AS pizza_revenue,
        0.30 * CAST(REPLACE(REPLACE(ro.distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) AS runner_payment
    FROM customer_orders co
    JOIN pizza_names p ON co.pizza_id = p.pizza_id
    JOIN runner_orders ro ON co.order_id = ro.order_id
    WHERE ro.cancellation IS NULL OR ro.cancellation = '' OR LOWER(ro.cancellation) = 'null'
    GROUP BY co.order_id, ro.distance
) AS order_costs;