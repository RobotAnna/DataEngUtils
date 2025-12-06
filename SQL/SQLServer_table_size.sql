SQLServer_table_size.sql
USE <database name>;
GO
SET NOCOUNT ON;
IF EXISTS(SELECT name FROM tempdb..sysobjects WHERE name='#tmp_objlist')
DROP TABLE #tmp_objlist;

CREATE TABLE #tmp_objlist(
lname VARCHAR(50),
lrows INT,
lreserved VARCHAR(15),
ldata VARCHAR(15),
lindex_sze VARCHAR(15),
lunused VARCHAR(15)
)
;

GO
DECLARE @tblname VARCHAR(50);
DECLARE tblname CURSOR FOR (
SELECT s.name+'.'+t.name AS obj_name
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.type_desc = 'USER_TABLE'
)
OPEN tblname
FETCH NEXT FROM tblname INTO @tblname
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO #tmp_objlist
--EXEC sp_spaceused @tblname
EXEC sp_spaceused @oneresultset=1, @objname=N'@tblname';
FETCH NEXT FROM tblname INTO @tblname
END
CLOSE tblname
;

DEALLOCATE tblname;
GO
SELECT *
FROM #tmp_objlist;
-- DROP TABLE #tmp_objlist;