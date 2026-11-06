TRUNCATE TABLE monitoring.expected_schedules;

INSERT INTO monitoring.expected_schedules VALUES
    ('dwh.LOAD_SOCIAL_NETWORK', '0 3 * * *', 'CSV соцсети -> stg -> Data Vault -> аналитические витрины');
INSERT INTO monitoring.expected_schedules VALUES
    ('monitoring.LOAD_SYSTEM_MARTS', '*/15 * * * *', 'метаданные Airflow -> системные витрины');

COMMIT;
