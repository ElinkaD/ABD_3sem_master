INSERT INTO dds.l_chat_owners (hk_l_owner_id, hk_person_id, hk_group_id, source, load_date)
SELECT DISTINCT hash(g.owner_id, g.id), hash(g.owner_id), hash(g.id), 'groups.csv', now()
FROM stg.groups g
WHERE hash(g.owner_id, g.id) NOT IN (SELECT hk_l_owner_id FROM dds.l_chat_owners);
