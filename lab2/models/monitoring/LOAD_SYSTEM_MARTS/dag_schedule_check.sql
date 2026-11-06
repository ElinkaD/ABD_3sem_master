DELETE FROM monitoring.dag_schedule_check;

INSERT INTO monitoring.dag_schedule_check
    (dag_id, expected_schedule, actual_schedule, is_registered, is_present, is_cron_valid,
     is_schedule_match, is_paused, has_import_errors, task_count, next_run_at,
     last_run_start, last_run_state, is_overdue, check_status, checked_at)
WITH last_runs AS (
    SELECT dag_id, run_id, MIN(COALESCE(start_date, end_date)) AS run_start,
           CASE
               WHEN SUM(CASE WHEN state IN ('failed', 'upstream_failed') THEN 1 ELSE 0 END) > 0 THEN 'failed'
               WHEN SUM(CASE WHEN state IN ('running', 'queued', 'scheduled') OR state IS NULL THEN 1 ELSE 0 END) > 0 THEN 'running'
               ELSE 'success'
           END AS run_state,
           ROW_NUMBER() OVER (PARTITION BY dag_id ORDER BY MIN(COALESCE(start_date, end_date)) DESC NULLS LAST) AS rn
    FROM stg.airflow_task_runs
    GROUP BY dag_id, run_id
),
checks AS (
    SELECT COALESCE(e.dag_id, d.dag_id) AS dag_id,
           e.expected_schedule,
           d.schedule AS actual_schedule,
           e.dag_id IS NOT NULL AS is_registered,
           COALESCE(d.is_active, FALSE) AS is_present,
           d.is_cron_valid,
           e.expected_schedule = d.schedule AS is_schedule_match,
           d.is_paused,
           d.has_import_errors,
           d.task_count,
           d.next_run_at,
           lr.run_start AS last_run_start,
           lr.run_state AS last_run_state,
           COALESCE(NOT d.is_paused AND d.next_run_at < d.snapshot_at - INTERVAL '1 hour', FALSE) AS is_overdue,
           COALESCE(d.snapshot_at, now()) AS checked_at
    FROM monitoring.expected_schedules e
    FULL JOIN stg.airflow_dags d ON d.dag_id = e.dag_id
    LEFT JOIN last_runs lr ON lr.dag_id = COALESCE(e.dag_id, d.dag_id) AND lr.rn = 1
)
SELECT dag_id, expected_schedule, actual_schedule, is_registered, is_present, is_cron_valid,
       is_schedule_match, is_paused, has_import_errors, task_count, next_run_at,
       last_run_start, last_run_state, is_overdue,
       CASE
           WHEN NOT is_present THEN 'MISSING'
           WHEN NOT is_registered THEN 'NOT_REGISTERED'
           WHEN has_import_errors THEN 'IMPORT_ERROR'
           WHEN NOT is_cron_valid THEN 'INVALID_CRON'
           WHEN NOT is_schedule_match THEN 'SCHEDULE_MISMATCH'
           WHEN is_paused THEN 'PAUSED'
           WHEN is_overdue THEN 'OVERDUE'
           WHEN last_run_state = 'failed' THEN 'LAST_RUN_FAILED'
           ELSE 'OK'
       END,
       checked_at
FROM checks;
