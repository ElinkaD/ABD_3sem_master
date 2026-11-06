DELETE FROM cdm.messages_monthly;

INSERT INTO cdm.messages_monthly (report_month, messages_cnt, senders_cnt, groups_cnt, loaded_at)
SELECT TRUNC(hc.msg_time, 'MM')::DATE,
       COUNT(*),
       COUNT(DISTINCT lpc.hk_person_id),
       COUNT(DISTINCT lg.hk_group_id),
       now()
FROM dds.h_chats hc
LEFT JOIN dds.l_person_chat lpc ON lpc.hk_msg_id = hc.hk_msg_id
LEFT JOIN dds.l_groups lg ON lg.hk_msg_id = hc.hk_msg_id
WHERE hc.msg_time IS NOT NULL
GROUP BY TRUNC(hc.msg_time, 'MM')::DATE;
