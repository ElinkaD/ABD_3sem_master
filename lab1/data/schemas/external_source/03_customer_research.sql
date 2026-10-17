-- Оболочка таблицы маркетинговых исследований.
CREATE TABLE IF NOT EXISTS external_source.customer_research (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_id DATE NOT NULL CHECK (isfinite(date_id)),
    geo_id BIGINT NOT NULL CHECK (geo_id > 0),
    sales_qty INTEGER NOT NULL CHECK (sales_qty >= 0),
    sales_amt NUMERIC(14, 2) NOT NULL
        CHECK (sales_amt BETWEEN 0 AND 999999999999.99),
    loaded_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS customer_research_loaded_idx
    ON external_source.customer_research (loaded_at DESC, id DESC);
