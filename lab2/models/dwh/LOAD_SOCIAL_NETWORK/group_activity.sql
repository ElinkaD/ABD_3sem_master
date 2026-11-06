DELETE FROM cdm.group_activity;

INSERT INTO cdm.group_activity
    (group_id, title, created_date, owner_id, owner_name, messages_cnt, senders_cnt,
     first_msg_time, last_msg_time, loaded_at)
WITH group_info AS (
    SELECT hk_group_id, title,
           ROW_NUMBER() OVER (PARTITION BY hk_group_id ORDER BY load_date DESC) AS rn
    FROM dds.s_group_info
),
person_info AS (
    SELECT hk_person_id, name,
           ROW_NUMBER() OVER (PARTITION BY hk_person_id ORDER BY load_date DESC) AS rn
    FROM dds.s_person_info
),
messages AS (
    SELECT lg.hk_group_id, hc.msg_time, lpc.hk_person_id
    FROM dds.l_groups lg
    JOIN dds.h_chats hc ON hc.hk_msg_id = lg.hk_msg_id
    LEFT JOIN dds.l_person_chat lpc ON lpc.hk_msg_id = lg.hk_msg_id
)
SELECT hg.group_id,
       gi.title,
       hg.created_date,
       hp.person_id,
       pi.name,
       COUNT(m.msg_time),
       COUNT(DISTINCT m.hk_person_id),
       MIN(m.msg_time),
       MAX(m.msg_time),
       now()
FROM dds.h_groups hg
LEFT JOIN group_info gi ON gi.hk_group_id = hg.hk_group_id AND gi.rn = 1
LEFT JOIN dds.l_chat_owners lco ON lco.hk_group_id = hg.hk_group_id
LEFT JOIN dds.h_people hp ON hp.hk_person_id = lco.hk_person_id
LEFT JOIN person_info pi ON pi.hk_person_id = lco.hk_person_id AND pi.rn = 1
LEFT JOIN messages m ON m.hk_group_id = hg.hk_group_id
GROUP BY hg.group_id, gi.title, hg.created_date, hp.person_id, pi.name;
