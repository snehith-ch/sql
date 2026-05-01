USE company;
GO

/*
T-SQL Programming setup

Run this file before reading/solving:
- tsql_programming_revision_notebook.md
- tsql_programming_practice.sql

This setup supports the lesson examples for:
- variables
- PRINT vs SELECT
- simple stored procedures
- input parameters
- account balance lookup
- product/category lookup
*/

DROP PROCEDURE IF EXISTS dbo.usp_tsql_add_numbers_lesson;
DROP PROCEDURE IF EXISTS dbo.usp_tsql_get_account_balance_lesson;
DROP PROCEDURE IF EXISTS dbo.usp_tsql_get_products_by_category_lesson;
GO

DROP TABLE IF EXISTS dbo.TSQL_PRODUCT_MASTER;
DROP TABLE IF EXISTS dbo.TSQL_ACCOUNT_MASTER;
GO

CREATE TABLE dbo.TSQL_ACCOUNT_MASTER
(
    ACID INT PRIMARY KEY,
    CUST_NAME VARCHAR(50) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    CBAL MONEY NOT NULL,
    STATUS CHAR(1) NOT NULL
);
GO

CREATE TABLE dbo.TSQL_PRODUCT_MASTER
(
    PRODUCT_ID INT PRIMARY KEY,
    PRODUCT_NAME VARCHAR(80) NOT NULL,
    CATEGORY VARCHAR(30) NOT NULL,
    PRICE MONEY NOT NULL,
    STOCK_QTY INT NOT NULL
);
GO

INSERT INTO dbo.TSQL_ACCOUNT_MASTER
    (ACID, CUST_NAME, CITY, CBAL, STATUS)
VALUES
    (101, 'Anil Rao', 'Hyderabad', 15000, 'A'),
    (102, 'Bhavya Shah', 'Bengaluru', 22000, 'A'),
    (103, 'Charan Das', 'Chennai', 8000, 'A'),
    (104, 'Deepa Nair', 'Mumbai', 500, 'I'),
    (105, 'Farhan Ali', 'Hyderabad', 35000, 'A');
GO

INSERT INTO dbo.TSQL_PRODUCT_MASTER
    (PRODUCT_ID, PRODUCT_NAME, CATEGORY, PRICE, STOCK_QTY)
VALUES
    (1, 'SQL Server Book', 'Books', 750, 20),
    (2, 'Power BI Guide', 'Books', 650, 12),
    (3, 'Wireless Mouse', 'Electronics', 900, 35),
    (4, 'Mechanical Keyboard', 'Electronics', 2800, 8),
    (5, 'Notebook Pack', 'Stationery', 180, 50),
    (6, 'Marker Set', 'Stationery', 120, 40);
GO

SELECT 'T-SQL programming setup completed' AS SETUP_STATUS;
SELECT * FROM dbo.TSQL_ACCOUNT_MASTER;
SELECT * FROM dbo.TSQL_PRODUCT_MASTER;
GO

