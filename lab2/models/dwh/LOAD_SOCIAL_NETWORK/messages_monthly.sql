DELETE FROM cdm.messages_monthly;

INSERT INTO cdm.messages_monthly (report_month, messages_cnt, senders_cnt, groups_cnt, loaded_at)
WITH msg_groups AS (
    SELECT hk_msg_id, hk_group_id
    FROM dds.l_groups
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
),
msg_authors AS (
    SELECT hk_msg_id, hk_person_id
    FROM dds.l_person_chat
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
)
SELECT TRUNC(hc.msg_time, 'MM')::DATE,
       COUNT(*),
       COUNT(DISTINCT ma.hk_person_id),
       COUNT(DISTINCT mg.hk_group_id),
       now()
FROM dds.h_chats hc
LEFT JOIN msg_authors ma ON ma.hk_msg_id = hc.hk_msg_id
LEFT JOIN msg_groups mg ON mg.hk_msg_id = hc.hk_msg_id
WHERE hc.msg_time IS NOT NULL
GROUP BY TRUNC(hc.msg_time, 'MM')::DATE;
