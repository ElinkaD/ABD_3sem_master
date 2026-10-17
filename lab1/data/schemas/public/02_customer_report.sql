-- Расчётные поля соответствуют исходному SELECT из отчёта, в том же порядке.
CREATE TABLE IF NOT EXISTS public.customer_report (
    id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    customer_name VARCHAR,
    customer_address VARCHAR,
    customer_birthday DATE,
    customer_email VARCHAR,
    customer_money NUMERIC,
    platform_money NUMERIC,
    count_order BIGINT,
    avg_price_order NUMERIC,
    median_time_order_completed DOUBLE PRECISION,
    product_type VARCHAR,
    craftsman_id BIGINT,
    count_order_created BIGINT,
    count_order_in_progress BIGINT,
    count_order_delivery BIGINT,
    count_order_done BIGINT,
    count_order_not_done BIGINT,
    report_period TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL,
    UNIQUE (customer_id, report_period)
);
CREATE INDEX IF NOT EXISTS customer_report_loaded_idx
    ON public.customer_report (loaded_at DESC, id DESC);
