-- ----------------------------------------------------------------------------
-- File: Generate_random_table.sql
--
-- Create test table of x rows, containing random values
--
-- Author: Nerrida Dempster
-- Date: 07/09/2021
-- ----------------------------------------------------------------------------

-- Set your role, database, schema
USE ROLE dev_nl_engineer;
USE DATABASE dev_nl;
USE SCHEMA working;

DROP TABLE IF EXISTS working.nd_bool_test;
CREATE TABLE working.nd_bool_test AS (
SELECT
  seq4() AS Seq
, uniform(0, 1, random(7)) AS Ind_Int -- Integer filter
, TO_CHAR(uniform(0, 1, random(7))) AS Ind_Chr -- Varchar filter
, TO_BOOLEAN(uniform(0, 1, random(7))) AS Ind_Boo -- Boolean filter
, randstr(15, random()) AS RndTxt1 -- Random string, 15 characters long. It would be
possible to randomize the length too, if necessary.
, randstr(15, random()) AS RndTxt2
, randstr(15, random()) AS RndTxt3
, randstr(15, random()) AS RndTxt4
, randstr(15, random()) AS RndTxt5
FROM TABLE(generator(rowcount =&gt; 50000000)) v -- Set the number of rows. Currently 50 million rows
ORDER BY 1
);

-- Test: run each once, check query history.
-- (In this test I was comparing runtimes of different datatypes as filters)
SELECT * FROM WORKING.ND_BOOL_TEST WHERE Ind_Int = 1;
SELECT * FROM WORKING.ND_BOOL_TEST WHERE Ind_Chr = &#39;1&#39;;
SELECT * FROM WORKING.ND_BOOL_TEST WHERE Ind_Boo = TRUE;
