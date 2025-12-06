-- -----------------------------------------------------------------------
-- example GREATEST and MAX
-- -----------------------------------------------------------------------
WITH cte AS (
    SELECT 1 AS ind, 2 AS iets, 3 AS niets, 4.00 AS bah UNION ALL
    SELECT 2, 4,   -1, -2.00 UNION ALL
    SELECT 3, 6, NULL, 13.45
)

-- search column iets, return the largest value
-- implies a "GROUP BY"
--SELECT MAX(iets) FROM cte

-- search each row, return the largest value within the columns
-- implies no grouping
--SELECT GREATEST(ind, iets, niets, bah) FROM cte

-- error. you can't group and not group in the same statement.
--SELECT MAX(ind), GREATEST(iets, niets, bah) FROM cte

-- so you dont need to do a NVL or IFNULL
--SELECT GREATEST(iets, niets), GREATEST_IGNORE_NULLS(iets, niets) FROM cte

-- SQL scripting: use ARRAY_MAX to find greatest value within an array. Ignores nulls.
-- returns a variant
SELECT ind, iets, niets, bah,
    ARRAY_MAX([iets, niets, bah]),
    ARRAY_MIN([iets, niets, bah])
FROM cte
;


SELECT * FROM THT.SSV_LOCATIE l;
SELECT * FROM THT.SSV_LOCATIE_DETAIL d;



-- -------------------------------------------------------------------------------------------
-- dimEvenement
-- -------------------------------------------------------------------------------------------
Wisten jullie dat Snowflake GREATEST en LEAST functies heeft? Dat maakt het een stuk eenvoudiger om twee tabellen met geldigheidsperiodes op elkaar te joinen waarbij je een geldigheidsperiode van het resultaat teruggeeft:
WITH cte_return_validity_periods AS (
    SELECT
        l.SSV_LOCATIE_CODE,
        l.SSV_LOCATIE AS STATIONLOCATIE,
        d.SSV_LOCATIEDETAIL_CODE,
        d.SSV_LOCATIE_DETAIL,
        GREATEST(l.GELDIGVANAF, d.GELDIGVANAF) AS GELDIGVANAF,
        LEAST(l.GELDIGTM, d.GELDIGTM) AS GELDIGTM
    FROM
        THT.SSV_LOCATIE l
        INNER JOIN THT.SSV_LOCATIE_DETAIL d
            ON l.SSV_LOCATIE_CODE = d.SSV_LOCATIE_CODE
            AND l.GELDIGTM >= d.GELDIGVANAF
            AND l.GELDIGVANAF <= d.GELDIGTM
    WHERE
        GREATEST(l.GELDIGVANAF, d.GELDIGVANAF) <= LEAST(l.GELDIGTM, d.GELDIGTM)
)
SELECT * FROM cte_return_validity_periods;
