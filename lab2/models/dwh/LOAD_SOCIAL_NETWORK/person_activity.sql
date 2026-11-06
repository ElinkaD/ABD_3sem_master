DELETE FROM cdm.person_activity;

INSERT INTO cdm.person_activity
    (person_id, name, country, messages_sent, groups_owned, groups_written, last_msg_time, loaded_at)
WITH person_info AS (
    SELECT hk_person_id, name, country,
           ROW_NUMBER() OVER (PARTITION BY hk_person_id ORDER BY load_date DESC) AS rn
    FROM dds.s_person_info
),
sent AS (
    SELECT lpc.hk_person_id,
           COUNT(*) AS messages_sent,
           COUNT(DISTINCT lg.hk_group_id) AS groups_written,
           MAX(hc.msg_time) AS last_msg_time
    FROM dds.l_person_chat lpc
    JOIN dds.h_chats hc ON hc.hk_msg_id = lpc.hk_msg_id
    LEFT JOIN dds.l_groups lg ON lg.hk_msg_id = lpc.hk_msg_id
    GROUP BY lpc.hk_person_id
),
owned AS (
    SELECT hk_person_id, COUNT(*) AS groups_owned
    FROM dds.l_chat_owners
    GROUP BY hk_person_id
)
SELECT hp.person_id,
       pi.name,
       pi.country,
       COALESCE(s.messages_sent, 0),
       COALESCE(o.groups_owned, 0),
       COALESCE(s.groups_written, 0),
       s.last_msg_time,
       now()
FROM dds.h_people hp
LEFT JOIN person_info pi ON pi.hk_person_id = hp.hk_person_id AND pi.rn = 1
LEFT JOIN sent s ON s.hk_person_id = hp.hk_person_id
LEFT JOIN owned o ON o.hk_person_id = hp.hk_person_id;
