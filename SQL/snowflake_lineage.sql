-- -------------------------------------------------------------------------------------------------------
--
-- What references SV_EDM objects?
--
-- -------------------------------------------------------------------------------------------------------
SELECT 
  referencing_database
, referencing_schema
, referencing_object_name
, referencing_object_domain
, referenced_database
, referenced_schema
, referenced_object_name
, referenced_object_domain
, CASE
    WHEN referenced_object_name LIKE '%VARIABLE%' THEN 'utility'
    WHEN referenced_database = referencing_database AND referenced_schema = referencing_schema THEN 'relation'
    ELSE 'source'
END AS relation_type
FROM snowflake.account_usage.object_dependencies
WHERE 1=1
AND referenced_database      = 'DIASSV'
AND referenced_schema        IN ('STG_HIST')
AND LOWER(referenced_object_name) LIKE '%imk_inzethulpdiensten_enddate%'
;
