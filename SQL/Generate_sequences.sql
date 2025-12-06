/* ----------------------------------------------------------------------------

EXAMPLE: Snowflake SQL

Generate a sequence of dates using SEQ4() and Table(Generator(Rowcount&lt;=x))
You could also use this to generate a sequence of integers.

---------------------------------------------------------------------------- */
SET varDateIDStart = '1950-01-01';
SET varMaxRows = 55152; -- Number of days after start date. This corresponds to end date 2100-12-31;

WITH CTE_DateList AS (
SELECT DATEADD(DAY, SEQ4(), $varDateIDStart) AS vDate
FROM TABLE(GENERATOR(ROWCOUNT=&gt;$varMaxRows))
)
SELECT
TO_CHAR(vDate, 'yyyymmdd') AS DateCode
, vDate AS vDate
, MONTH(vDate) AS vMonth
, QUARTER(vDate) AS vQuarter
, YEAR(vDate) AS vYear
, DAYOFYEAR(vDate) AS Day_In_Year
, DAY(vDate) AS Day_In_Month
, DAYOFWEEK(vDate) AS Day_In_Week
, WEEKOFYEAR(vDate) AS Week_In_Year
FROM CTE_DateList
ORDER BY 1
;
