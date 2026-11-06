DELETE FROM cdm.group_activity;

INSERT INTO cdm.group_activity
    (group_id, title, created_date, owner_id, owner_name, messages_cnt, senders_cnt,
     first_msg_time, last_msg_time, loaded_at)
WITH group_info AS (
    SELECT hk_group_id, title
    FROM dds.s_group_info
    LIMIT 1 OVER (PARTITION BY hk_group_id ORDER BY load_date DESC)
),
person_info AS (
    SELECT hk_person_id, name
    FROM dds.s_person_info
    LIMIT 1 OVER (PARTITION BY hk_person_id ORDER BY load_date DESC)
),
owners AS (
    SELECT hk_group_id, hk_person_id
    FROM dds.l_chat_owners
    LIMIT 1 OVER (PARTITION BY hk_group_id ORDER BY load_date DESC)
),
msg_groups AS (
    SELECT hk_msg_id, hk_group_id
    FROM dds.l_groups
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
),
msg_authors AS (
    SELECT hk_msg_id, hk_person_id
    FROM dds.l_person_chat
    LIMIT 1 OVER (PARTITION BY hk_msg_id ORDER BY load_date DESC)
),
messages AS (
    SELECT mg.hk_group_id, hc.msg_time, ma.hk_person_id
    FROM msg_groups mg
    JOIN dds.h_chats hc ON hc.hk_msg_id = mg.hk_msg_id
    LEFT JOIN msg_authors ma ON ma.hk_msg_id = mg.hk_msg_id
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
LEFT JOIN group_info gi ON gi.hk_group_id = hg.hk_group_id
LEFT JOIN owners o ON o.hk_group_id = hg.hk_group_id
LEFT JOIN dds.h_people hp ON hp.hk_person_id = o.hk_person_id
LEFT JOIN person_info pi ON pi.hk_person_id = o.hk_person_id
LEFT JOIN messages m ON m.hk_group_id = hg.hk_group_id
GROUP BY hg.group_id, gi.title, hg.created_date, hp.person_id, pi.name;
