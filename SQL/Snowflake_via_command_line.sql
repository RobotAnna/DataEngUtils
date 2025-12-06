/* ----------------------------------------------------------------------------

Instructions to use Snowflake SQL
Author: Nerrida Dempster
Date: 17/08/2021
See documentation at the Snowflake website
https://docs.snowflake.com/en/user-guide/snowsql-install-config.html
Download and install SnowSQL

---------------------------------------------------------------------------- */


/*
Connect using SSO.
For this to work, use a terminal application that is capable of launching a browser,
eg. Windows Terminal. If the command seems to hang for a long time, alt-tab to your
default web browser, and it should then open the authenticator.
*/
snowsql -a <department account>.privatelink -w PT_NL_S -u <user email address capital letters> -r <role> --authenticator externalbrowser
use database <database name>;
use schema REF;
truncate table REF_BRON;
!source V2.0__InsertRefRecords.sql

-- Examples: process the SQL files from the current directory.
!source <file name>.sql

-- Ctrl-D to exit

