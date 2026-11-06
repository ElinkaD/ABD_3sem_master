INSERT INTO dds.h_groups (hk_group_id, group_id, created_date, source, load_date)
SELECT DISTINCT hash(g.id), g.id, g.created_date, 'groups.csv', now()
FROM stg.groups g
WHERE hash(g.id) NOT IN (SELECT hk_group_id FROM dds.h_groups);

INSERT INTO dds.h_groups (hk_group_id, group_id, created_date, source, load_date)
SELECT DISTINCT hash(c.msg_group_id), c.msg_group_id, NULL, 'chats.csv', now()
FROM stg.chats c
WHERE c.msg_group_id IS NOT NULL
  AND hash(c.msg_group_id) NOT IN (SELECT hk_group_id FROM dds.h_groups);
