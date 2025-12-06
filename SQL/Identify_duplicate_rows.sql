-- ----------------------------------------------------------------------------
-- File: Identify_duplicate_rows.sql
--
-- Identify duplicate rows from a specific table.
-- It assumes the data has only a primary key in column 1. If there's a composite
-- key it will be reported as a duplicate.
--
-- Author: Nerrida Dempster

-- Date: 10/09/2021
-- ----------------------------------------------------------------------------

-- Step 1: build a set of queries, for all tables in a specific database and schema
SET varDB = 'database_name';
SET varSchema = 'schema_name';
SELECT 'SELECT \''||t.Table_Name||'\' AS TableName, \''||c.column_name||'\' AS IndexName, TO_CHAR('||c.column_name||') AS IndexVal, COUNT('||c.column_name||') AS RowCount FROM '||t.table_catalog||'.'||t.table_schema||'.'||t.table_name||' GROUP BY '||c.column_name||' HAVING COUNT('||c.column_name||') > 1 UNION ALL ' AS Query_Txt
FROM information_schema.tables t
JOIN Information_Schema.Columns c ON t.table_catalog = c.table_catalog
AND t.table_schema = c.table_schema
AND t.table_name = c.table_name
AND c.ordinal_position = 1
WHERE t.table_catalog = $varDB
AND t.table_schema = $varSchema
AND t.table_type= 'BASE TABLE'
;

-- Step 2: copy/paste the results back into this worksheet, then run it as one large query
SELECT TableName, COUNT(1) AS DuplicateCount FROM (

SELECT 'D_AGENT' AS TableName, 'D_AGENT_ID' AS IndexName, TO_CHAR(D_AGENT_ID) AS IndexVal, COUNT(D_AGENT_ID) AS RowCount FROM database_name.schema_name.D_AGENT GROUP BY D_AGENT_ID HAVING COUNT(D_AGENT_ID) > 1 UNION ALL
SELECT 'D_BRON' AS TableName, 'D_BRON_ID' AS IndexName, TO_CHAR(D_BRON_ID) AS IndexVal, COUNT(D_BRON_ID) AS RowCount FROM database_name.schema_name.D_BRON GROUP BY D_BRON_ID HAVING COUNT(D_BRON_ID) > 1 UNION ALL
SELECT 'D_DATUM' AS TableName, 'D_DATUM_ID' AS IndexName, TO_CHAR(D_DATUM_ID) AS IndexVal, COUNT(D_DATUM_ID) AS RowCount FROM database_name.schema_name.D_DATUM GROUP BY D_DATUM_ID HAVING COUNT(D_DATUM_ID) > 1 UNION ALL
SELECT 'D_KLANT' AS TableName, 'D_KLANT_ID' AS IndexName, TO_CHAR(D_KLANT_ID) AS IndexVal, COUNT(D_KLANT_ID) AS RowCount FROM database_name.schema_name.D_KLANT GROUP BY D_KLANT_ID HAVING COUNT(D_KLANT_ID) > 1 UNION ALL
SELECT 'D_LABEL' AS TableName, 'D_LABEL_ID' AS IndexName, TO_CHAR(D_LABEL_ID) AS IndexVal, COUNT(D_LABEL_ID) AS RowCount FROM database_name.schema_name.D_LABEL GROUP BY D_LABEL_ID HAVING COUNT(D_LABEL_ID) > 1 UNION ALL
SELECT 'D_TERMIJN' AS TableName, 'D_TERMIJN_ID' AS IndexName, TO_CHAR(D_TERMIJN_ID) AS IndexVal, COUNT(D_TERMIJN_ID) AS RowCount FROM database_name.schema_name.D_TERMIJN GROUP BY D_TERMIJN_ID HAVING COUNT(D_TERMIJN_ID) > 1 UNION ALL
SELECT 'F_BETALING' AS TableName, 'BDV_SQN' AS IndexName, TO_CHAR(BDV_SQN) AS IndexVal, COUNT(BDV_SQN) AS RowCount FROM database_name.schema_name.F_BETALING GROUP BY BDV_SQN HAVING COUNT(BDV_SQN) > 1 UNION ALL
SELECT 'F_CONNECTIE' AS TableName, 'BDV_SQN' AS IndexName, TO_CHAR(BDV_SQN) AS IndexVal, COUNT(BDV_SQN) AS RowCount FROM database_name.schema_name.F_CONNECTIE GROUP BY BDV_SQN HAVING COUNT(BDV_SQN) > 1 UNION ALL
SELECT 'F_CONTACT' AS TableName, 'BDV_SQN' AS IndexName, TO_CHAR(BDV_SQN) AS IndexVal, COUNT(BDV_SQN) AS RowCount FROM database_name.schema_name.F_CONTACT GROUP BY BDV_SQN HAVING COUNT(BDV_SQN) > 1

) GROUP BY TableName
;

