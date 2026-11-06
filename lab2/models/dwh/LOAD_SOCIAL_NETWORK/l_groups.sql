INSERT INTO dds.l_groups (hk_l_group_id, hk_msg_id, hk_group_id, source, load_date)
SELECT DISTINCT hash(c.msg_id, c.msg_group_id), hash(c.msg_id), hash(c.msg_group_id), 'chats.csv', now()
FROM stg.chats c
WHERE c.msg_group_id IS NOT NULL
  AND hash(c.msg_id, c.msg_group_id) NOT IN (SELECT hk_l_group_id FROM dds.l_groups);
