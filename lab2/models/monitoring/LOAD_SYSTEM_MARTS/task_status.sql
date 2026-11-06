DELETE FROM monitoring.task_status;

INSERT INTO monitoring.task_status
    (dag_id, task_id, last_run_id, last_state, last_try_number, last_start, last_end,
     last_duration_sec, runs_30d, success_30d, failed_30d, success_rate_30d,
     avg_duration_sec, last_failure_at, checked_at)
WITH runs AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY dag_id, task_id
                              ORDER BY COALESCE(start_date, end_date) DESC NULLS LAST, run_id DESC) AS rn
    FROM stg.airflow_task_runs
)
SELECT dag_id,
       task_id,
       MAX(CASE WHEN rn = 1 THEN run_id END),
       MAX(CASE WHEN rn = 1 THEN state END),
       MAX(CASE WHEN rn = 1 THEN try_number END),
       MAX(CASE WHEN rn = 1 THEN COALESCE(start_date, end_date) END),
       MAX(CASE WHEN rn = 1 THEN end_date END),
       MAX(CASE WHEN rn = 1 THEN duration END),
       COUNT(*),
       SUM(CASE WHEN state = 'success' THEN 1 ELSE 0 END),
       SUM(CASE WHEN state IN ('failed', 'upstream_failed') THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN state = 'success' THEN 1 ELSE 0 END) / COUNT(*), 2),
       AVG(duration),
       MAX(CASE WHEN state = 'failed' THEN end_date END),
       MAX(snapshot_at)
FROM runs
GROUP BY dag_id, task_id;
