DROP TABLE IF EXISTS wrk.customer_research;

CREATE TABLE wrk.customer_research (
    date_id DATE CHECK (isfinite(date_id)),
    category_id TEXT,
    geo_id BIGINT CHECK (geo_id > 0),
    sales_qty INTEGER CHECK (sales_qty >= 0),
    sales_amt NUMERIC(14, 2)
        CHECK (sales_amt BETWEEN 0 AND 999999999999.99)
);