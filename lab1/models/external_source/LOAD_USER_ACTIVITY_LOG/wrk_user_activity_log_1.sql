DROP TABLE IF EXISTS wrk.user_activity_log;

CREATE TABLE wrk.user_activity_log (
    "Id" TEXT,
    uniq_id TEXT,
    date_time TIMESTAMP CHECK (isfinite(date_time)),
    action_id TEXT,
    customer_id BIGINT CHECK (customer_id > 0),
    quantity TEXT
);