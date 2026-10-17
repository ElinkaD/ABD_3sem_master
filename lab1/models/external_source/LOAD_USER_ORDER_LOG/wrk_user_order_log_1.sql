DROP TABLE IF EXISTS wrk.user_order_log;

CREATE TABLE wrk.user_order_log (
    id TEXT,
    uniq_id TEXT,
    date_time TIMESTAMP CHECK (isfinite(date_time)),
    city_id TEXT,
    city_name TEXT,
    customer_id BIGINT CHECK (customer_id > 0),
    first_name TEXT,
    last_name TEXT,
    item_id TEXT,
    item_name TEXT,
    quantity INTEGER CHECK (quantity >= 0),
    payment_amount NUMERIC(14, 2)
        CHECK (payment_amount BETWEEN 0 AND 999999999999.99)
);