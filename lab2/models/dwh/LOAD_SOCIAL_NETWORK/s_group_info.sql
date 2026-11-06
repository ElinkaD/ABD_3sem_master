INSERT INTO dds.s_group_info (hk_group_id, title, status, hashdiff, source, load_date)
SELECT src.hk_group_id, src.title, NULL, src.hashdiff, 'groups.csv', now()
FROM (
    SELECT hash(g.id) AS hk_group_id, g.group_name AS title, hash(g.group_name) AS hashdiff
    FROM stg.groups g
) src
LEFT JOIN (
    SELECT hk_group_id, hashdiff,
           ROW_NUMBER() OVER (PARTITION BY hk_group_id ORDER BY load_date DESC) AS rn
    FROM dds.s_group_info
) cur ON cur.hk_group_id = src.hk_group_id AND cur.rn = 1
WHERE cur.hashdiff IS NULL OR cur.hashdiff <> src.hashdiff;
