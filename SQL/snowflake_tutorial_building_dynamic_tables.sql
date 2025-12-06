/*********************************************************************************************************************************
DYNAMIC TABLES: A quick demo

Dynamic tables are a new declarative way of defining your data pipeline in Snowflake, for both batch and streaming use cases. It's a new kind of Snowflake table which is defined as a query and Snowflake continuously and automatically materializes the result of that query as a table. 

You can create transformation pipelines by chaining dynamic tables together into a graph, reading from tables, views, and other dynamic tables, without the need to set up any orchestration. In this Tutorial you will learn how to create and manage a data pipeline using dynamic tables with sample data.

*********************************************************************************************************************************/

-- First we'll set the context and create a database for the sample data. You can drop this database at the end of this tutorial. 

CREATE DATABASE IF NOT EXISTS DEMO;
CREATE SCHEMA IF NOT EXISTS DEMO.DT_TUTORIAL;
USE SCHEMA DEMO.DT_TUTORIAL;

CREATE WAREHOUSE IF NOT EXISTS XSMALL_WH
 WITH WAREHOUSE_SIZE = 'XSMALL'
 AUTO_SUSPEND = 60
 AUTO_RESUME = TRUE
 INITIALLY_SUSPENDED = TRUE;

use warehouse xsmall_wh;

/***********************************************************************************
STEP 1 - SETUP SAMPLE DATA FOR TUTORIAL
***********************************************************************************/
-- In this step, we'll create a few sample data tables to store customer information, product stock, and purchases. 

-- To start, we'll create a customer information table:
create or replace TABLE CUST_INFO (
	CUSTID NUMBER(10,0),
	CNAME VARCHAR(100),
	SPENDLIMIT NUMBER(10,2)
);

insert into cust_info values (1001,'John Villarreal',8187.42);
insert into cust_info values (1002,'Austin Carroll',4933.94);
insert into cust_info values (1003,'Connie Curtis',5217.71);
insert into cust_info values (1004,'Michael Harrison',3003.78);
insert into cust_info values (1005,'Amanda Mendoza',3382.70);

select * from cust_info limit 10;

-- Next, we’ll create a product stock table where each product has a stock level from fulfillment day:
create or replace TABLE PROD_STOCK_INV (
	PID NUMBER(10,0),
	PNAME VARCHAR(100),
	STOCK NUMBER(10,2),
	STOCKDATE DATE
);

insert into prod_stock_inv values( 101,'Wooden pegs',500,'2023-12-15');
insert into prod_stock_inv values( 102,'Automated desk',600,'2023-12-15');
insert into prod_stock_inv values( 103,'Multi-layered widtgh',300,'2023-12-15');
insert into prod_stock_inv values( 104,'Quantum tester',100,'2023-12-15');
insert into prod_stock_inv values( 105,'Vision-oriented product',700,'2023-12-15');

select * from prod_stock_inv limit 10;

-- Lastly, we'll create a table for sales data with products purchased online by various customers:
create or replace TABLE SALESDATA (
	CUSTID NUMBER(10,0),
	PURCHASE VARIANT
);

insert into salesdata select 1001,PARSE_JSON('{"prodid": 101,"purchase_amount": 919.8,"purchase_date": "2023-12-20","quantity": 4}');
insert into salesdata select 1001,PARSE_JSON('{"prodid": 102,"purchase_amount": 505.05,"purchase_date": "2023-12-21","quantity": 4}');
insert into salesdata select 1002,PARSE_JSON('{"prodid": 103,"purchase_amount": 898.92,"purchase_date": "2023-12-21","quantity": 3}');
insert into salesdata select 1004,PARSE_JSON('{"prodid": 104,"purchase_amount": 852.52,"purchase_date": "2023-12-20","quantity": 5}');
insert into salesdata select 1003,PARSE_JSON('{"prodid": 105,"purchase_amount": 546.43,"purchase_date": "2023-12-21","quantity": 2}');

select * from salesdata limit 10;


/***********************************************************************************
STEP 2 - BUILD DATA PIPELINE USING DYNAMIC TABLES
***********************************************************************************/
-- In this step, we’ll build our first dynamic table by selecting the sales information from the sales data table and join it with customer information. 

CREATE OR REPLACE DYNAMIC TABLE customer_sales_data_history
    LAG='DOWNSTREAM'
    WAREHOUSE=xsmall_wh
AS
select 
    s.custid as customer_id,
    c.cname as customer_name,
    s.purchase:"prodid"::number(5) as product_id,
    s.purchase:"purchase_amount"::number(10) as saleprice,
    s.purchase:"quantity"::number(5) as quantity,
    s.purchase:"purchase_date"::date as salesdate
from
    cust_info c inner join salesdata s on c.custid = s.custid
;

-- We’ll do a quick sanity check on our newly created dynamic table:
select * from customer_sales_data_history limit 10;

-- Now, we’ll combine these results with the product table and create a SCD TYPE 2 transformation with the customer's latest purchase as the current record and maintain old purchase history as well. 
CREATE OR REPLACE DYNAMIC TABLE salesreport
    LAG = '1 MINUTE'
    WAREHOUSE=xsmall_wh
AS
    select
        t1.customer_id,
        t1.customer_name, 
        t1.product_id,
        p.pname as product_name,
        t1.saleprice,
        t1.quantity,
        (t1.saleprice/t1.quantity) as unitsalesprice,
        t1.salesdate as CreationTime,
        customer_id || '-' || t1.product_id  || '-' || t1.salesdate AS CUSTOMER_SK,
        LEAD(CreationTime) OVER (PARTITION BY t1.customer_id ORDER BY CreationTime ASC) AS END_TIME
    from 
        customer_sales_data_history t1 inner join prod_stock_inv p 
        on t1.product_id = p.pid
       
;

select * from salesreport;
select count(*) from salesreport;

-- We’ll add a few new records into the salesdata table: 
insert into salesdata select 1002,PARSE_JSON('{"prodid": 105,"purchase_amount": 200.8,"purchase_date": "2023-12-25","quantity": 6}');
insert into salesdata select 1005,PARSE_JSON('{"prodid": 102,"purchase_amount": 500,"purchase_date": "2023-12-25","quantity": 3}');

-- And check on the raw table: 
select count(*) from salesdata;

/*********************************************************************************************************
Dynamic tables build a data pipeline directed acyclic graph (DAG). You can use Snowsight to visualize and monitor the DAG of your pipeline by going to Data > Databases > DEMO > DT_TUTORIAL > dynamic tables. 
*********************************************************************************************************/

select count(*) from customer_sales_data_history;
select count(*) from salesreport;

/*********************************************************************************************************
You can also monitor your dynamic table with a quick show command. It will display all the dynamic tables and the relevant properties in the current schema.
*********************************************************************************************************/

show dynamic tables;

/*********************************************************************************************************
You’ve reached the end of this tutorial. In this tutorial, you learned how to build a data pipeline and monitor it using dynamic table DAGS. To learn more about dynamic tables, visit Snowflake Documentation: https://docs.snowflake.com/en/user-guide/dynamic-tables-about 

You can clean up the sample database and schema used in this tutorial with the below commands. 

*********************************************************************************************************/

drop schema DT_TUTORIAL;
drop database DEMO;

/* To learn more about DT’s follow a larger quickstart at https://quickstarts.snowflake.com/guide/getting_started_with_dynamic_tables/index.html
*/
