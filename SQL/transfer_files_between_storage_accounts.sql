CREATE OR REPLACE PROCEDURE STG.USP_Transfer_ABC()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'run'
EXECUTE AS OWNER
AS
$$

from datetime import datetime
#import json5 as js

# handler function
def run(session):

    log_run_date = datetime.now()            

    # global parameters
    log_table        = 'MGT.ABC_LOGGING'
    processing_table = 'MGT.ABC_BRON_LANDING'
    prestage_table   = 'STG.ABC_BRON_PRESTAGE'
    #config_table     = 'MGT.ABC_BRON_CONFIGURATIE' # LATER: improve the stored proc by using parameters + configuration table, instead of hard-coded source-specific variables
    force_load       = False # Set to True for unit test, or when reloading files. Otherwise keep it as False.

    # source-specific parameters: should be passed in, or retrieved from config table
    bron         = 'SOURCENAME'
    bron_bestand = 'subset'
    van_stage    = '@stg.SOURCENAME'
    van_dataset  = 'raw/dataset=subset'
    file_type    = 'XML'
    naar_stage   = '@stg.ABC_SOURCES_SOURCENAME'


    ## Generic Functions ################################################################################
    def log(text, topic=''):
        # logs text to a log table
        if text:
            text = str(text).replace("'", "\\'")
        if not topic:
            topic = 'TRANSFER_'+bron

        if text and topic and log_table:
            log_query = f"""
                insert into {log_table} (logdate, rundate, topic, text)
                values('{datetime.now()}', '{log_run_date}', '{topic}', '{text}');
                """
            run_query(log_query)


    def run_query(sql_query, return_output_dict=False):
        df = session.sql(sql_query)
        df_collect = df.collect()
        if return_output_dict:
            try:
                # Snowflake adds double quotes to non-capital names
                output_dict = {column.replace('"', ''): [] for column in df.columns}
                for row in df_collect:
                    for column in output_dict.keys():
                        output_dict[column].append(row[column])
                return output_dict
            except Exception as error:
                log(f'unable to create query output dict, error: {error}')


    def truncate_table(table_name):
        log(f'truncate table: {table_name}'.replace('  ', ' '))
        run_query(f'truncate table {table_name}')
    


    ## Procedural Functions ################################################################################

    def copy_metadata_into_prestage():
        log(f'-begin: copy_metadata_into_prestage')

        # truncate prestage table
        truncate_table(prestage_table)

        # prepare query
        # Column FileData is not used. It is included to force one record in the prestage table per file, even if there are multiple rows in the file
        copy_into_sub_query = (f"""
            SELECT
                '{bron}'                            AS Bron
            ,   '{bron_bestand}'                    AS Bron_Bestand
            ,   CURRENT_TIMESTAMP()                 AS Timestamp_Prestage
            ,   '{van_stage}'                       AS Stage_In
            ,   METADATA$FILENAME                   AS BestandsPad
            ,   $1                                  AS FileData
            FROM {van_stage}/{van_dataset}/
            """)
        copy_into_prestage_query = f"""
            copy into {prestage_table} from ({copy_into_sub_query})
            file_format = (type={file_type})
            force       = {force_load}
            """
        # run query
        log(f'copy files into prestage query: {copy_into_prestage_query}')
        log(f'copy files into prestage result: {run_query(copy_into_prestage_query, return_output_dict=True)}')



    def copy_files_to_archive():
        log(f'-begin: copy_files_to_archive')

        # prepare query -- currently hard-coded to one specific source. This should be made generic, use config table for source-specific prefixes.
        # DISTINCT in the child query, because there should be one copy command per directory, not per file
        generate_copy_files_query = (f"""
            SELECT 'COPY FILES INTO {naar_stage}'||Prefix_Archief||
            ' FROM {van_stage}'||Prefix_Lake AS CMD
            FROM (
                SELECT DISTINCT
                    '/'||SUBSTR(BestandsPad, 1, LENGTH(BestandsPad) - LENGTH(SPLIT_PART(BestandsPad, '/', -1))) AS Prefix_Lake
                ,   '/'||SUBSTR(BestandsPad,22,46)                                                              AS Prefix_Archief
                FROM {prestage_table}
            )
            """)

        # generate the copy commands
        log(f'generate copy commands: {generate_copy_files_query}')
        commands_dict = run_query(generate_copy_files_query, return_output_dict=True)
        log(f'commands_dict: {commands_dict}')
        
        # run the copy commands
        if commands_dict:
            if 'CMD' in commands_dict:
                for command in commands_dict['CMD']:
                    log(f'loop through copy commands: {command}')
                    run_query(command)
            else:
                log(f'no files to copy: {command}')



    def merge_results_into_delivery_table():
        log(f'-begin: merge_results_into_delivery_table')

        # prepare query -- currently hard-coded to one source. This should be made generic, use config table for source-specific prefixes.
        generate_logging_query = (f"""
            INSERT INTO EDW.MGT.ABC_BRON_LANDING (
            	Bron
            ,	Bron_Bestand
            ,   Timestamp_Prestage
            ,   Naar_Stage
            ,   Timestamp_Landing
            ,   BestandsPad
            ,	BestandsNaam
            )
            SELECT DISTINCT
                '{bron}'                                AS Bron
            ,   '{bron_bestand}'                        AS Bron_Bestand
            ,   p.Timestamp_Prestage
            ,   '{naar_stage}/'                         AS Naar_Stage
            ,   METADATA$FILE_LAST_MODIFIED             AS Timestamp_Landing
            ,   METADATA$FILENAME                       AS BestandsPad
            ,	SPLIT_PART(METADATA$FILENAME, '/', -1)  AS BestandsNaam
            FROM {naar_stage}/    AS r
            JOIN {prestage_table} AS p ON SUBSTR(p.BestandsPad,22) = r.METADATA$FILENAME
            """)

        # run query
        run_query(generate_logging_query)
        log(f'wrote logging to table: {processing_table}')



    #########################################################################
    # main execution                                                        #
    #########################################################################

    log(f'******** TRANSFER start:{datetime.now()}')

    # Run the 4 steps in order: load parameters, copy metadata into prestage, copy files to archive, log the results.
    try:
        #load_parameters()
        copy_metadata_into_prestage()
        copy_files_to_archive()
        merge_results_into_delivery_table()
    except Exception as error:
        error_message = f'process stopped. Error occurred: {error}'
        log(error_message)
        return error_message

    log(f'******** TRANSFER end:{datetime.now()}')
    return 'SUCCESS'

$$
;