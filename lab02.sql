-- ФИО: Родионова К.М.
-- Группа: ИНБО-20-23
-- Вариант: 1 (X = SP, Y = RJ)
-- Практическая работа №2. Множества и мультимножества в SQL

-- =====================================================================
-- Множество A: product_id товаров, купленных клиентами из штата SP,
--             только по доставленным заказам (order_status = 'delivered')
-- =====================================================================
\echo '=== A: count(*) и count(DISTINCT product_id) ==='
SELECT count(*) AS a_rows, count(DISTINCT product_id) AS a_distinct
FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered';

-- =====================================================================
-- Множество B: product_id товаров, купленных клиентами из штата RJ,
--             только по доставленным заказам
-- =====================================================================
\echo '=== B: count(*) и count(DISTINCT product_id) ==='
SELECT count(*) AS b_rows, count(DISTINCT product_id) AS b_distinct
FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered';

-- =====================================================================
-- 1. UNION (без дубликатов) и UNION ALL (с дубликатами)
-- =====================================================================
\echo '=== 1. A UNION B (уникальные product_id) ==='
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
UNION
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered';

\echo '=== 2. A UNION ALL B (с дубликатами) ==='
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
UNION ALL
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered';

-- Сравнение мощностей: UNION — уникальные, UNION ALL — все строки.
\echo '=== 1b. Мощности: |A|, |B|, |A UNION B|, |A UNION ALL B| ==='
WITH a AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
),
b AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
)
SELECT
  (SELECT count(*) FROM a)                                 AS a_card,
  (SELECT count(*) FROM b)                                 AS b_card,
  (SELECT count(*) FROM (SELECT * FROM a UNION SELECT * FROM b) u)     AS union_card,
  (SELECT count(*) FROM (SELECT * FROM a UNION ALL SELECT * FROM b) ua) AS union_all_card;

-- =====================================================================
-- 3. Пересечение A ∩ B через INTERSECT
-- =====================================================================
\echo '=== 3. A INTERSECT B ==='
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
INTERSECT
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered';

\echo '=== 3b. Мощность |A ∩ B| ==='
WITH a AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
),
b AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
)
SELECT count(*) AS intersect_card FROM (SELECT * FROM a INTERSECT SELECT * FROM b) t;

-- =====================================================================
-- 4. Разность A − B и B − A через EXCEPT
-- =====================================================================
\echo '=== 4a. A EXCEPT B (есть у SP, нет у RJ) ==='
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
EXCEPT
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered';

\echo '=== 4b. B EXCEPT A (есть у RJ, нет у SP) ==='
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
EXCEPT
SELECT product_id FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered';

-- =====================================================================
-- 5. Коммутативность объединения и пересечения
-- =====================================================================
\echo '=== 5. Коммутативность: |A UNION B| vs |B UNION A| ==='
WITH a AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
),
b AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
)
SELECT
  (SELECT count(*) FROM (SELECT * FROM a UNION SELECT * FROM b) t) AS ab,
  (SELECT count(*) FROM (SELECT * FROM b UNION SELECT * FROM a) t) AS ba;

\echo '=== 5b. Коммутативность: |A INTERSECT B| vs |B INTERSECT A| ==='
WITH a AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
),
b AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
)
SELECT
  (SELECT count(*) FROM (SELECT * FROM a INTERSECT SELECT * FROM b) t) AS ab,
  (SELECT count(*) FROM (SELECT * FROM b INTERSECT SELECT * FROM a) t) AS ba;

-- =====================================================================
-- 6. Некоммутативность разности: |A EXCEPT B| vs |B EXCEPT A|
-- =====================================================================
\echo '=== 6. Некоммутативность: |A EXCEPT B| vs |B EXCEPT A| ==='
WITH a AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
),
b AS (
  SELECT DISTINCT oi.product_id
  FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
)
SELECT
  (SELECT count(*) FROM (SELECT * FROM a EXCEPT SELECT * FROM b) t) AS a_minus_b,
  (SELECT count(*) FROM (SELECT * FROM b EXCEPT SELECT * FROM a) t) AS b_minus_a;

-- =====================================================================
-- 7. Пересечение без INTERSECT — через EXISTS
-- =====================================================================
\echo '=== 7. A ∩ B через EXISTS ==='
SELECT DISTINCT product_id
FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
  AND EXISTS (
    SELECT 1
    FROM olist.order_items oi2
    JOIN olist.orders    o2 ON o2.order_id = oi2.order_id
    JOIN olist.customers c2 ON c2.customer_id = o2.customer_id
    WHERE oi2.product_id = oi.product_id
      AND c2.customer_state = 'RJ'
      AND o2.order_status = 'delivered'
  );

-- =====================================================================
-- 8. Демонстрация дубликатов: без DISTINCT в UNION (обычный UNION их уберёт,
--    а вот UNION ALL — оставит; и без DISTINCT в одиночном запросе тоже
--    появятся дубликаты из-за join-ов)
-- =====================================================================
\echo '=== 8a. Без DISTINCT: сколько строк у A (join-ы дают дубликаты) ==='
SELECT count(*) AS a_with_dups
FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered';

\echo '=== 8b. С DISTINCT: столько уникальных product_id в A ==='
SELECT count(DISTINCT product_id) AS a_distinct
FROM olist.order_items oi
JOIN olist.orders    o ON o.order_id = oi.order_id
JOIN olist.customers c ON c.customer_id = o.customer_id
WHERE c.customer_state = 'SP' AND o.order_status = 'delivered';

\echo '=== 8c. UNION ALL: размер мультимножества ==='
SELECT count(*) AS union_all_size FROM (
  SELECT product_id FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'SP' AND o.order_status = 'delivered'
  UNION ALL
  SELECT product_id FROM olist.order_items oi
  JOIN olist.orders    o ON o.order_id = oi.order_id
  JOIN olist.customers c ON c.customer_id = o.customer_id
  WHERE c.customer_state = 'RJ' AND o.order_status = 'delivered'
) t;

-- =====================================================================
-- 9. комментарий: какие операции возвращают множество, а какие —
--    мультимножество
-- =====================================================================
-- UNION
-- UNION ALL
-- INTERSECT
-- INTERSECT ALL 
-- EXCEPT  
-- EXCEPT ALL    
-- SELECT ... FROM ... JOIN ...
