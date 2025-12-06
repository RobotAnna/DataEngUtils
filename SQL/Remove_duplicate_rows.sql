-- ----------------------------------------------------------------------------
-- File: Remove_duplicate_rows.sql
--
-- Remove duplicate rows from a specific table, without recreating the table.
-- To be used if there were operational issues during a data migration.
--
-- Author: Nerrida Dempster
-- Date: 03/09/2021
-- ----------------------------------------------------------------------------

-- back up the table, just in case
CREATE OR REPLACE TABLE database_name.schema_name.F_CONTACT_BACKUP AS
SELECT * FROM database_name.schema_name.F_CONTACT;

-- find all duplicates
create or replace transient table duplicate_ids as (
select bdv_sqn
from database_name.schema_name.F_CONTACT
group by bdv_sqn
having count(*)>1
);

create or replace transient table duplicate_row as (
select distinct a.*
from database_name.schema_name.F_CONTACT a
join duplicate_ids b on a.bdv_sqn = b.bdv_sqn
);

-- use a transaction to insert and delete
begin transaction;

-- delete duplicates
delete from database_name.schema_name.F_CONTACT a
using duplicate_ids b
where (a.bdv_sqn)=(b.bdv_sqn);

-- insert single copy
insert into database_name.schema_name.F_CONTACT
select *
from duplicate_row;

-- we are done
commit;

-----------------------------------------
-- check row counts
select 'F_CONTACT' as table_name, count(1) as row_count from database_name.schema_name.F_CONTACT union all
select 'F_CONTACT_BACKUP' as table_name, count(1) as row_count from database_name.schema_name.F_CONTACT_BACKUP
;
-- 35 rows difference :) hooray
