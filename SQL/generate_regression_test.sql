-- Om te vergelijken NSRA oud vs nieuwe keten’s, je kunt deze query gebruiken. Dit werkt voor de tabellen met enkel PK (id), het werkt nog niet voor de tabellen met combi PK (bijv journeyIncidents).

-- test inhoud ---------------------------------------------------------------------
WITH pk_list AS (
     SELECT 'AssistanceApplicants'    AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'AssistanceProviders'     AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'AvpServices'             AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Carriers'                AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'ComplaintCategories'     AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'ComplaintHistories'      AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Complaints'              AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Dossiers'                AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Incidents'               AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'JourneyIncidents'        AS table_name, 'journey_id, incident_id'              AS pk_column UNION ALL
     SELECT 'JourneyNotes'            AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'JourneyParts'            AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Journeys'                AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'OpeningPeriods'          AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'OpeningTimeBlocks'       AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'OriginalTripRequests'    AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'PASServiceEvents'        AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'PASServiceIncidents'     AS table_name, 'passervice_id, incident_id'           AS pk_column UNION ALL
     SELECT 'PASServices'             AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'PlatformOccupations'     AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'PlatformRestrictions'    AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Platforms'               AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'ServiceTypePASServices'  AS table_name, 'servicetype_id, passervice_id'        AS pk_column UNION ALL
     SELECT 'ServiceTypes'            AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Stations'                AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'SupportToolCustomers'    AS table_name, 'supporttool_id, customer_id'          AS pk_column UNION ALL
     SELECT 'SupportToolJourneys'     AS table_name, 'supporttool_id, journey_id'           AS pk_column UNION ALL
     SELECT 'SupportTools'            AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TaxiPartIncidents'       AS table_name, 'taxipart_id, incident_id'             AS pk_column UNION ALL
     SELECT 'TaxiParts'               AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TaxiReasons'             AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TrainParts'              AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TrainRestrictions'       AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TrainRideElements'       AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TrainRides'              AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TransferObjectPlatforms' AS table_name, 'transferobject_id, platform_id'       AS pk_column UNION ALL
     SELECT 'TransferObjects'         AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TripElements'            AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TripLegIncidents'        AS table_name, 'tripleg_id, incident_id'              AS pk_column UNION ALL
     SELECT 'TripLegMessages'         AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'TripLegs'                AS table_name, 'id'                                   AS pk_column UNION ALL
     SELECT 'Trips'                   AS table_name, 'id'                                   AS pk_column 
)
SELECT 
  c.table_catalog
, c.table_schema
, c.table_name
, p.pk_column
, 'SELECT '''||c.table_name||''' AS table_name, COUNT(1) AS aantal_records, SUM(IFF(HASH('
||LISTAGG('d.'||c.column_name,',') WITHIN GROUP (ORDER BY c.column_name) ||') = HASH('
||LISTAGG('e.'||c.column_name,',') WITHIN GROUP (ORDER BY c.column_name)||') = TRUE,1,0)) AS aantal_records_matched FROM '||c.table_catalog||'.'||c.table_schema||'.'||c.table_name||' d LEFT JOIN EDW.'||c.table_schema||'.'||c.table_name||' e ON d.id = e.id AND e.iscurrent = 1 WHERE d.iscurrent = 1 GROUP BY ALL UNION ALL ' AS query_text
FROM information_schema.columns AS c
JOIN information_schema.tables  AS t ON c.table_catalog = t.table_catalog AND c.table_schema = t.table_schema AND c.table_name = t.table_name
JOIN pk_list                    AS p ON 'PAS_'||UPPER(p.table_name) = c.table_name
WHERE t.table_catalog = 'DIASSV'
AND t.table_type      = 'BASE TABLE'
AND t.table_schema    = 'STG_HIST'
AND t.table_name      LIKE 'PAS%'
AND p.pk_column = 'id'
AND c.column_name     NOT IN ( 'BESTANDSPAD', 'EXTRACTIEDATUM', 'LOADDATE', 'EVENTDATE', 'ENDDATE', 'EVENTENDDATE', 'ISCURRENT', 'ISCURRENTEVENT', 'ISDELETED', 'HASHDIFF', 'RECORDSOURCE', 'AUDITID', 'ISNEW', 'ISCHANGE' )
GROUP BY ALL
ORDER BY 1,2,3
;



--De query genereerd een grote query (met union all’s). Bijv.

SELECT 'PAS_ASSISTANCEAPPLICANTS' AS table_name, COUNT(1) AS aantal_records, SUM(IFF(HASH(d.CONTACT,d.EMAIL,d.ID,d.ISACTIVE,d.ISNSPARTNER,d.NAME,d.PHONENUMBER) = HASH(e.CONTACT,e.EMAIL,e.ID,e.ISACTIVE,e.ISNSPARTNER,e.NAME,e.PHONENUMBER) = TRUE,1,0)) AS aantal_records_matched FROM DIASSV.STG_HIST.PAS_ASSISTANCEAPPLICANTS d LEFT JOIN EDW.STG_HIST.PAS_ASSISTANCEAPPLICANTS e ON d.id = e.id AND e.iscurrent = 1 WHERE d.iscurrent = 1 GROUP BY ALL UNION ALL


-- Het vergelijkt oud en nieuwe PAS tabellen in ontwikkel omgeving, en rapporteert of er een match is.


--In het geval van AssistanceApplicants is de oorzaak bekend: oude keten heeft true/false koloms met kleine letters, “true”, en nieuwe keten heeft koloms als “True” / “False”.
/* 
Zoals jullie al weet:
•	Snowflake ontwikkel heeft 1 maand van databestanden in de 2x stages: PAS en NSRA
•	Stg_hist is geladen in DIASSV en EDW van deze 2x stages.
•	De test uitslag ligt op sharepoint

Nadat de upper/lower issue is opgelost zou het goed zijn om de query nog een keer te draaien. Waarschijnlijk komt iets anders naar boven.
*/