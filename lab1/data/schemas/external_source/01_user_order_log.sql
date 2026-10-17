-- Оболочка таблицы заказов: поля CSV по ТЗ и технические id/loaded_at.
CREATE TABLE IF NOT EXISTS external_source.user_order_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL CHECK (isfinite(date_time)),
    customer_id BIGINT NOT NULL CHECK (customer_id > 0),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    payment_amount NUMERIC(14, 2) NOT NULL
        CHECK (payment_amount BETWEEN 0 AND 999999999999.99),
    loaded_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS user_order_log_loaded_idx
    ON external_source.user_order_log (loaded_at DESC, id DESC);
