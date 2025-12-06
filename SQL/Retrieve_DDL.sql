-- -------------------------------------------------------------------------------
-- Retrieve DDL
--
-- It's easier to use INFORMATION_SCHEMA, but this may remove line endings.
-- Calling function get_ddl preserves formatting.
--
-- Author: Nerrida Dempster
-- Date: 08/09/2021
-- -------------------------------------------------------------------------------

-- Generates the script to extract DDL
WITH table_list AS (
    SELECT table_catalog, table_schema, table_name, DECODE(table_type,'BASE TABLE','table','view') as ttype
    FROM information_schema.tables
    WHERE table_schema  = 'INSERT_SCHEMA_NAME_HERE'
)
SELECT 'select get_ddl(\''||ttype||'\',\''||table_catalog||'.'||table_schema||'.'||table_name||'\') union all'
FROM table_list
WHERE ttype = 'view'
;


-- Paste results to Notepad, then copy/paste into the worksheet
select get_ddl('view', 'database_name.schema_name.view_name') union all
select get_ddl('view', 'database_name.schema_name.view_name') union all
;

