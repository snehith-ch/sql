USE company;
GO

/*
Lesson 31 Workbook: Joins vs Subqueries, EXISTS, System Metadata Queries, and Deployment Checks

Run lesson31_setup.sql first.
This workbook uses:
- dbo.ACCOUNT_DEMO_L31
- dbo.TRANSACTION_DEMO_L31
- dbo.EMPLOYEE_L31
- dbo.SALES_L31

==================================================
1. Current Lesson Topics From Transcript
==================================================
- when to use joins vs subqueries / correlated subqueries
- EXISTS as a Boolean function
- using EXISTS when you need to check something from another table but do not want to display that table's columns
- system tables / metadata objects discussed by the trainer:
  sys.tables, sys.columns, sys.databases, sys.procedures, sys.triggers
- system tables vs user tables
- system databases vs user databases
- counting tables in a database
- counting columns in a table
- getting columns of a table using object_id
- finding the table name for a given column name
- joining sys.tables and sys.columns
- IF EXISTS for drop-and-create scripts
- IF NOT EXISTS for create scripts
- generating repetitive SQL using concatenation
- month-wise number of new customers interview assignment

==================================================
2. Previously Covered Topics Needed Here
==================================================
- SELECT, WHERE
- joins
- subqueries
- correlated subqueries
- EXISTS / NOT EXISTS idea
- concatenation with +
- COUNT(*)
- aliases

==================================================
3. Important Points From Transcript
==================================================
- Use joins when you need to display data from all participating tables.
- Use subqueries or correlated subqueries when another table is needed only for condition checking, comparison, or existence checks, but its columns are not displayed.
- EXISTS is a Boolean-style function for existence checking.
- If at least one matching row is found, EXISTS becomes true.
- If no row is found, EXISTS becomes false.
- sys.tables helps you see table metadata in the current database.
- sys.columns helps you see column metadata.
- object_id links a table to its columns in metadata queries.
- The trainer emphasized that counting rows and counting columns are different interview questions.

==================================================
4. Interview Tricks From Transcript
==================================================
- "Count rows in a table" and "count columns in a table" are not the same question.
- If the interviewer asks which table contains a given column, join sys.columns and sys.tables.
- You can use concatenation with sys.tables to generate many `DROP TABLE` or `SELECT *` statements quickly.
- A subquery can be used to get object_id first, then use it to find columns of a specific table.
- If you do not need to display data from table 2, a subquery or correlated subquery may be a better fit than a join.

==================================================
5. Common Mistakes / Warnings From Transcript
==================================================
- Do not manually count tables from Object Explorer when sys.tables can do it.
- Do not confuse `name` from sys.tables with `name` from sys.columns.
- Do not assume the current database context is correct; metadata queries depend on the current database.
- Do not use joins unnecessarily when you only need existence checking.

==================================================
6. Best Practices / Practical Tips From Transcript
==================================================
- Keep a few metadata queries ready in your "interview pocket."
- Use metadata queries to explore unfamiliar databases quickly after joining a company.
- Use generated scripts for repetitive work instead of typing each statement manually.
- For deployment-style scripts, check existence first before dropping or creating objects.

==================================================
7. SQL Rules / Query Rules / Interview Rules
==================================================
- Use joins when you need output columns from multiple tables.
- Use subqueries / correlated subqueries when another table is used only for checking or filtering.
- EXISTS returns true if at least one matching row exists; otherwise false.
- sys.tables returns table-level metadata for the current database.
- sys.columns returns column-level metadata for the current database.
- To get all columns of one table, first identify the table's object_id.
- To count columns of a table, count rows in sys.columns for that object_id.
- To find which table contains a column, join sys.columns and sys.tables on object_id.
- `IF EXISTS` is commonly used before drop operations.
- `IF NOT EXISTS` is commonly used before create operations.
- Concatenation can generate executable SQL text like `DROP TABLE table_name`.

==================================================
8. Beginner-Friendly Notes
==================================================
System vs User:
- User tables are the business tables we create.
- System metadata objects store information about tables, columns, procedures, triggers, and databases.

Metadata Query Idea:
- Instead of opening each table manually, query metadata objects.

EXISTS:
- It checks whether something exists.
- In this lesson, it is used both for data existence thinking and object existence checks.

==================================================
9. Syntax Section
==================================================

List all tables in current database:
SELECT * FROM sys.tables;

Count tables in current database:
SELECT COUNT(*) AS TABLE_COUNT
FROM sys.tables;

Get all columns of ACCOUNT_DEMO_L31:
SELECT *
FROM sys.columns
WHERE object_id = (
    SELECT object_id
    FROM sys.tables
    WHERE name = 'ACCOUNT_DEMO_L31'
);

Count columns in ACCOUNT_DEMO_L31:
SELECT COUNT(*) AS COLUMN_COUNT
FROM sys.columns
WHERE object_id = (
    SELECT object_id
    FROM sys.tables
    WHERE name = 'ACCOUNT_DEMO_L31'
);

Find which table contains STATUS:
SELECT t.name AS TABLE_NAME, c.name AS COLUMN_NAME
FROM sys.columns AS c
INNER JOIN sys.tables AS t
    ON c.object_id = t.object_id
WHERE c.name = 'STATUS';

Check table existence and drop if needed:
IF EXISTS (
    SELECT *
    FROM sys.tables
    WHERE name = 'EMP_TEMP_L31'
)
    DROP TABLE dbo.EMP_TEMP_L31;

Create database if it does not exist:
IF NOT EXISTS (
    SELECT *
    FROM sys.databases
    WHERE name = 'Lesson31_Practice_DB'
)
    CREATE DATABASE Lesson31_Practice_DB;

Generate drop statements:
SELECT 'DROP TABLE ' + t.name AS DROP_SCRIPT
FROM sys.tables AS t
WHERE t.name LIKE '%L31';

Generate select statements:
SELECT 'SELECT * FROM ' + t.name AS SELECT_SCRIPT
FROM sys.tables AS t
WHERE t.name LIKE '%L31';

==================================================
10. Level 1: Basic Questions
==================================================
Write your answers below each question.
*/

-- L1-Q1. Show all rows from dbo.ACCOUNT_DEMO_L31.
select * from dbo.ACCOUNT_DEMO_L31

-- L1-Q2. Show all rows from dbo.SALES_L31.
select * from dbo.SALES_L31 

-- L1-Q3. Show all user tables in the current database using sys.tables.
select * from sys.tables

-- L1-Q4. Count the number of tables in the current database.
select COUNT(*) as TABLE_COUNT from sys.tables

-- L1-Q5. Show all columns of ACCOUNT_DEMO_L31 using sys.columns and a subquery.
select * from sys.columns where object_id = (select object_id from sys.tables where name='ACCOUNT_DEMO_L31')

-- L1-Q6. Count the number of columns in ACCOUNT_DEMO_L31.
select COUNT(*) as COLUMN_COUNT from sys.columns where object_id=(select object_id from sys.tables where name='ACCOUNT_DEMO_L31')

-- L1-Q7. Show all databases using sys.databases.
select * from sys.databases

-- L1-Q8. Show all stored procedures using sys.procedures.
select * from sys.procedures

-- L1-Q9. Show all triggers using sys.triggers.
select * from sys.triggers

-- L1-Q10. Write a comment: when should you use a JOIN instead of a subquery?
-- You should use a JOIN instead of a subquery when you need to display columns from both tables in the result. JOINs are designed to combine rows from two or more tables based on related columns, and they can be more efficient than subqueries when you need to retrieve data from multiple tables.

/*
==================================================
11. Level 2: Intermediate Questions
==================================================
*/

-- L2-Q1. Find which table(s) contain the column STATUS.
-- Show TABLE_NAME and COLUMN_NAME.
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name='STATUS'
-- L2-Q2. Find which table(s) contain the column ACID.
-- Show TABLE_NAME and COLUMN_NAME.
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name='ACID'

-- L2-Q3. Show all columns of TRANSACTION_DEMO_L31 using object_id from sys.tables.
select * from sys.columns where object_id = (select object_id from sys.tables where name='TRANSACTION_DEMO_L31')

-- L2-Q4. Count the number of columns in SALES_L31.
select COUNT(*) as COLUMN_COUNT from sys.columns where object_id = (select object_id from sys.tables where name='SALES_L31')

-- L2-Q5. Generate DROP TABLE statements for all lesson31 tables using sys.tables and concatenation.
select 'DROP TABLE ' + name from sys.tables where name like '%L31'

-- L2-Q6. Generate SELECT * statements for all lesson31 tables using sys.tables and concatenation.
select 'SELECT * FROM '+ name from sys.tables where name LIKE '%L31'

-- L2-Q7. Write an IF EXISTS script to drop EMP_TEMP_L31 if it exists.
IF EXISTS (select * from sys.tables where name = 'EMP_TEMP_L31') DROP TABLE dbo.EMP_TEMP_L31

-- L2-Q8. Write an IF NOT EXISTS script to create a database named Lesson31_Practice_DB.
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Lesson31_Practice_DB') CREATE DATABASE Lesson31_Practice_DB

/*
==================================================
12. Level 3: Interview-Style Questions
==================================================
*/

-- L3-Q1. Write a comment explaining the difference between counting rows in a table
-- and counting columns in a table.
-- Counting rows in a table refers to determining how many records or entries exist in that table, which can be done using COUNT(*). Counting columns in a table refers to determining how many fields or attributes are defined for that table, which can be done by counting the entries in sys.columns for that table's object_id. These are different concepts: one is about the number of data entries, and the other is about the structure of the table.

-- L3-Q2. The interviewer gives you a column name STATUS.
-- Write a query to identify in which table(s) it exists.
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name='STATUS'

-- L3-Q3. Write a query to identify all columns of ACCOUNT_DEMO_L31
-- without manually looking in Object Explorer.
select * from sys.columns where object_id = (select object_id from sys.tables where name='ACCOUNT_DEMO_L31')

-- L3-Q4. Write a comment explaining when to use JOIN
-- and when to use subquery / correlated subquery.
-- You should use JOIN when you need to retrieve and display columns from multiple tables in the same result set. JOINs are efficient for combining related data from different tables based on a common key. On the other hand, you should use a subquery or correlated subquery when you need to perform a condition check or filter based on another table, but you do not need to display any columns from that table. Subqueries can be more readable and easier to write for certain types of conditions, especially when checking for existence or comparing aggregated values.

-- L3-Q5. Write a script that drops EMP_TEMP_L31 if it exists,
-- then creates EMP_TEMP_L31 with EMPID and EMPNAME columns.
IF EXISTS (select * from sys.tables where name = 'EMP_TEMP_L31') DROP TABLE dbo.EMP_TEMP_L31
CREATE TABLE dbo.EMP_TEMP_L31 (EMPID INT PRIMARY KEY, EMPNAME VARCHAR(50) NOT NULL)

-- L3-Q6. Show ready-to-run DROP TABLE statements for every lesson31 table.
select 'DROP TABLE ' + name from sys.tables where name like '%L31'

/*
==================================================
13. Level 4: Real-World / Business-Style Questions
==================================================
*/

-- L4-Q1. The DBA wants to know all tables available in the current database.
select name from sys.tables

-- L4-Q2. The DBA wants to know how many tables are available in the current database.
select COUNT(*) as TABLE_COUNT from sys.tables

-- L4-Q3. The developer knows a column name STATUS but not the table name.
-- Find the table name(s).
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name='STATUS'

-- L4-Q4. The deployment script should create Lesson31_Practice_DB only if it does not already exist.
if not exists (select * from sys.databases where name = 'Lesson31_Practice_DB') create database Lesson31_Practice_DB

-- L4-Q5. The deployment script should drop EMP_TEMP_L31 only if it already exists.
IF EXISTS (select * from sys.tables where name = 'EMP_TEMP_L31') DROP TABLE dbo.EMP_TEMP_L31

-- L4-Q6. The team wants ready-to-run SELECT statements for every lesson31 table.
select 'SELECT * FROM ' + name from sys.tables where name like '%L31'

/*
==================================================
14. Level 5: Rapid Revision Questions
==================================================
*/

-- L5-Q1. Write one query to count tables in the current database.
select COUNT(*) as TABLE_COUNT from sys.tables

-- L5-Q2. Write one query to count columns in ACCOUNT_DEMO_L31.
select COUNT(*) as COLUMN_COUNT from sys.columns where object_id = (select object_id from sys.tables where name='ACCOUNT_DEMO_L31')

-- L5-Q3. Write one query to list tables containing STATUS.
select a.name as TABLE_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name='STATUS'

-- L5-Q4. Write one query to list all procedures.
select * from sys.procedures

-- L5-Q5. Write one IF EXISTS example.
IF EXISTS (select * from sys.tables where name = 'EMP_TEMP_L31') DROP TABLE dbo.EMP_TEMP_L31

-- L5-Q6. Write one IF NOT EXISTS example.
if not exists (select * from sys.databases where name = 'Lesson31_Practice_DB') create database Lesson31_Practice_DB

/*
==================================================
15. Mixed Interview Practice
==================================================
*/

-- MIX-Q1. Show TABLE_NAME and COLUMN_NAME for columns named STATUS or ACID,
-- sorted by TABLE_NAME.
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name IN ('STATUS', 'ACID') order by a.name

-- MIX-Q2. Generate DROP TABLE statements and SELECT * statements
-- for every lesson31 table.
select 'DROP TABLE ' + name from sys.tables where name like '%L31'
select 'SELECT * FROM ' + name from sys.tables where name like '%L31'

-- MIX-Q3. Write a short comment block explaining:
-- 1. when to use JOIN
-- 2. when to use subquery / correlated subquery
-- 3. how to count columns of a table
-- join is used when you need to display columns from multiple tables in the same result. Subqueries or correlated subqueries are used when you need to check for conditions or existence based on another table, but you do not need to display that table's columns. To count columns of a table, you can query sys.columns and filter by the object_id of the table, which can be obtained from sys.tables.

/*
==================================================
16. Optional Challenge Questions
==================================================
*/

-- CH-Q1. Transcript interview assignment:
-- From dbo.SALES_L31, return month-wise number of new customers.
-- A new customer is counted only in the first month they appear.
-- Output should include month number and count of new customers.
SELECT MONTH(SALES_DATE) AS MONTH, COUNT(DISTINCT CUSTOMER_CODE) AS NEW_CUSTOMERS
FROM dbo.SALES_L31
WHERE CUSTOMER_CODE NOT IN (SELECT CUSTOMER_CODE FROM dbo.SALES_L31 AS s2 WHERE s2.SALES_DATE < dbo.SALES_L31.SALES_DATE)
GROUP BY MONTH(SALES_DATE)

-- CH-Q2. Show all tables that contain either STATUS or AMOUNT columns.
select a.name as TABLE_NAME, b.name as COLUMN_NAME from sys.tables as a JOIN sys.columns as b on a.object_id = b.object_id where b.name IN ('STATUS', 'AMOUNT') order by a.name

-- CH-Q3. Write a script that drops and recreates EMP_TEMP_L31 safely.
IF EXISTS (select * from sys.tables where name = 'EMP_TEMP_L31') DROP TABLE dbo.EMP_TEMP_L31
CREATE TABLE dbo.EMP_TEMP_L31 (EMPID INT PRIMARY KEY, EMPNAME VARCHAR(50) NOT NULL)

-- CH-Q4. Write a comment explaining why metadata queries are useful
-- when you join a new company and see a database with many tables.
-- Metadata queries are useful when you join a new company because they allow you to quickly explore and understand the structure of the database without having to manually open each table. By querying sys.tables and sys.columns, you can get an overview of what tables exist, how many columns they have, and which columns are in which tables. This can help you identify where relevant data is stored and how to write your queries more efficiently.

/*
==================================================
17. Transcript Coverage Checklist
==================================================
Current transcript topics covered:
- when to use joins vs subqueries / correlated subqueries
- EXISTS as a Boolean existence-check concept
- system tables / metadata query idea
- system vs user tables
- system vs user databases
- sys.tables, sys.columns, sys.databases, sys.procedures, sys.triggers
- counting tables
- counting columns
- finding columns of a table using object_id
- finding table names for a given column
- IF EXISTS / IF NOT EXISTS
- generating SQL text with concatenation
- month-wise new-customer interview assignment

Previous topics reused for revision/practice:
- SELECT, WHERE
- subqueries
- correlated subqueries
- EXISTS
- concatenation
- COUNT(*)
- aliases

Topics mentioned in transcript but not deeply taught in this lesson:
- exact stored procedure details were not taught
- exact trigger details were not taught

Important transcript points not turned into direct questions:
- the trainer discussed system objects in simple practical terms for day-to-day work
- metadata queries are daily-use queries after joining a company

Setup files created for this lesson:
- lesson31_setup.sql

Run order for this lesson:
1. Run lesson31_setup.sql
2. Solve lesson31_workbook.sql
*/
