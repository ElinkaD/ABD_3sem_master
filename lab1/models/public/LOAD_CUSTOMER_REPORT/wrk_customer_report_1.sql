-- Задание 1, вариант 1. Витрина по заказчикам.
--
-- Данные о заказах приходят из двух источников:
-- 1) craft_market_orders_customers + craft_market_masters_products
-- 2) craft_market_orders + craft_market_customers (+ craft_market_craftsmans)
-- Сначала объединяем их в один плоский набор, затем считаем метрики
-- по заказчику и отчётному периоду.
--
-- Статусы заказа: 'created', 'in progress', 'delivery', 'done'.

DROP TABLE IF EXISTS wrk.customer_report;

CREATE TABLE wrk.customer_report AS
WITH all_orders AS (
    -- источник 1
    SELECT oc.order_id,
           oc.craftsman_id,
           oc.product_id,
           mp.product_type,
           mp.product_price,
           oc.order_created_date,
           oc.order_completion_date,
           oc.order_status,
           oc.customer_id,
           oc.customer_name,
           oc.customer_address,
           oc.customer_birthday,
           oc.customer_email
    FROM craft_market_orders_customers oc
    JOIN craft_market_masters_products mp
      ON mp.craftsman_id = oc.craftsman_id
     AND mp.product_id   = oc.product_id

    UNION

    -- источник 2
    SELECT o.order_id,
           o.craftsman_id,
           o.product_id,
           o.product_type,
           o.product_price,
           o.order_created_date,
           o.order_completion_date,
           o.order_status,
           c.customer_id,
           c.customer_name,
           c.customer_address,
           c.customer_birthday,
           c.customer_email
    FROM craft_market_orders o
    JOIN craft_market_customers c ON c.customer_id = o.customer_id
),

orders_with_period AS (
    SELECT *,
           to_char(order_created_date, 'YYYY-MM') AS report_period
    FROM all_orders
),

customers AS (
    SELECT DISTINCT ON (customer_id)
           customer_id,
           customer_name,
           customer_address,
           customer_birthday,
           customer_email
    FROM all_orders
    ORDER BY customer_id, order_created_date DESC
),

monthly AS (
    SELECT customer_id,
           report_period,
           SUM(product_price)                                    AS customer_money,
           SUM(product_price) * 0.1                              AS platform_money,
           COUNT(order_id)                                       AS count_order,
           AVG(product_price)                                    AS avg_price_order,
           PERCENTILE_CONT(0.5) WITHIN GROUP (
               ORDER BY order_completion_date - order_created_date
           ) FILTER (WHERE order_completion_date IS NOT NULL)    AS median_time_order_completed,
           COUNT(*) FILTER (WHERE order_status = 'created')      AS count_order_created,
           COUNT(*) FILTER (WHERE order_status = 'in progress')  AS count_order_in_progress,
           COUNT(*) FILTER (WHERE order_status = 'delivery')     AS count_order_delivery,
           COUNT(*) FILTER (WHERE order_status = 'done')         AS count_order_done,
           COUNT(*) FILTER (WHERE order_status <> 'done')        AS count_order_not_done
    FROM orders_with_period
    GROUP BY customer_id, report_period
),

top_category AS (
    SELECT customer_id, report_period, product_type
    FROM (
        SELECT customer_id,
               report_period,
               product_type,
               ROW_NUMBER() OVER (PARTITION BY customer_id, report_period
                                  ORDER BY COUNT(*) DESC, product_type) AS rn
        FROM orders_with_period
        GROUP BY customer_id, report_period, product_type
    ) t
    WHERE rn = 1
),

top_craftsman AS (
    SELECT customer_id, report_period, craftsman_id
    FROM (
        SELECT customer_id,
               report_period,
               craftsman_id,
               ROW_NUMBER() OVER (PARTITION BY customer_id, report_period
                                  ORDER BY COUNT(*) DESC, craftsman_id) AS rn
        FROM orders_with_period
        GROUP BY customer_id, report_period, craftsman_id
    ) t
    WHERE rn = 1
)

SELECT ROW_NUMBER() OVER (ORDER BY m.report_period, m.customer_id) AS "Идентификатор записи",
       m.customer_id                       AS "Идентификатор заказчика",
       c.customer_name                     AS "ФИО заказчика",
       c.customer_address                  AS "Адрес заказчика",
       c.customer_birthday                 AS "Дата рождения заказчика",
       c.customer_email                    AS "Электронная почта заказчика",
       m.customer_money                    AS "Сумма, потраченная заказчиком",
       m.platform_money                    AS "Доход платформы (10%)",
       m.count_order                       AS "Количество заказов",
       ROUND(m.avg_price_order, 2)         AS "Средняя стоимость заказа",
       m.median_time_order_completed       AS "Медиана выполнения заказа, дн",
       tc.product_type                     AS "Популярная категория товаров",
       tcr.craftsman_id                    AS "ID популярного мастера",
       m.count_order_created               AS "Количество созданных заказов",
       m.count_order_in_progress           AS "Количество заказов в изготовлении",
       m.count_order_delivery              AS "Количество заказов в доставке",
       m.count_order_done                  AS "Количество завершённых заказов",
       m.count_order_not_done              AS "Количество незавершённых заказов",
       m.report_period                     AS "Отчётный период (год-месяц)"
FROM monthly m
JOIN customers     c   ON c.customer_id = m.customer_id
JOIN top_category  tc  ON tc.customer_id = m.customer_id  AND tc.report_period  = m.report_period
JOIN top_craftsman tcr ON tcr.customer_id = m.customer_id AND tcr.report_period = m.report_period
ORDER BY m.report_period, m.customer_id;
