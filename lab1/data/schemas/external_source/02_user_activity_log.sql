-- Оболочка таблицы активности, независимо от заказов и исследований.
CREATE TABLE IF NOT EXISTS external_source.user_activity_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_time TIMESTAMP NOT NULL CHECK (isfinite(date_time)),
    customer_id BIGINT NOT NULL CHECK (customer_id > 0),
    loaded_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS user_activity_log_loaded_idx
    ON external_source.user_activity_log (loaded_at DESC, id DESC);
