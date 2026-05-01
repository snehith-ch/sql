USE company;
GO

/*
UDF combined setup

Run this file before:
- udf_combined_revision_notebook.md
- udf_combined_practice.sql

This setup supports examples for:
- scalar functions
- inline table-valued functions
- multi-statement table-valued functions
- table variables inside functions
- function calls in SELECT / INSERT / UPDATE / DELETE conditions
- seat number generation idea from the transcript
*/

DROP PROCEDURE IF EXISTS dbo.usp_udf_insert_movie_customer_lesson;
DROP FUNCTION IF EXISTS dbo.udf_get_next_seat_lesson;
DROP FUNCTION IF EXISTS dbo.udf_get_accounts_by_branch_lesson;
DROP FUNCTION IF EXISTS dbo.udf_get_account_snapshot_lesson;
DROP FUNCTION IF EXISTS dbo.udf_get_customer_balance_lesson;
DROP FUNCTION IF EXISTS dbo.udf_calculate_net_salary_lesson;
GO

DROP TABLE IF EXISTS dbo.UDF_MOVIE_CUSTOMER;
DROP TABLE IF EXISTS dbo.UDF_ACCOUNT_MASTER;
DROP TABLE IF EXISTS dbo.UDF_TXN_MASTER;
DROP TABLE IF EXISTS dbo.UDF_EMPLOYEE_PAY;
GO

CREATE TABLE dbo.UDF_ACCOUNT_MASTER
(
    ACID INT PRIMARY KEY,
    CUST_NAME VARCHAR(50) NOT NULL,
    BRID CHAR(3) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    CBAL MONEY NULL,
    STATUS CHAR(1) NOT NULL
);
GO

CREATE TABLE dbo.UDF_TXN_MASTER
(
    TXN_ID INT IDENTITY(1,1) PRIMARY KEY,
    ACID INT NOT NULL REFERENCES dbo.UDF_ACCOUNT_MASTER(ACID),
    DOT DATE NOT NULL,
    TXN_TYPE CHAR(3) NOT NULL,
    TXN_AMOUNT MONEY NOT NULL
);
GO

CREATE TABLE dbo.UDF_EMPLOYEE_PAY
(
    EMP_ID INT PRIMARY KEY,
    EMP_NAME VARCHAR(50) NOT NULL,
    BASIC_PAY MONEY NOT NULL,
    ALLOWANCE MONEY NOT NULL,
    PF_AMOUNT MONEY NOT NULL,
    TAX_AMOUNT MONEY NOT NULL
);
GO

CREATE TABLE dbo.UDF_MOVIE_CUSTOMER
(
    CUSTOMER_ID INT IDENTITY(1,1) PRIMARY KEY,
    SEAT_NO VARCHAR(3) NOT NULL UNIQUE,
    CUSTOMER_NAME VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(80) NOT NULL,
    PHONE_NO VARCHAR(20) NOT NULL
);
GO

INSERT INTO dbo.UDF_ACCOUNT_MASTER
    (ACID, CUST_NAME, BRID, CITY, CBAL, STATUS)
VALUES
    (101, 'Anil Rao', 'BR1', 'Hyderabad', 15000, 'A'),
    (102, 'Bhavya Shah', 'BR2', 'Bengaluru', 22000, 'A'),
    (103, 'Charan Das', 'BR1', 'Hyderabad', 8000, 'A'),
    (104, 'Deepa Nair', 'BR3', 'Mumbai', 500, 'I'),
    (105, 'Farhan Ali', 'BR2', 'Bengaluru', NULL, 'A'),
    (106, 'Gita Menon', 'BR3', 'Mumbai', 41000, 'A');
GO

INSERT INTO dbo.UDF_TXN_MASTER
    (ACID, DOT, TXN_TYPE, TXN_AMOUNT)
VALUES
    (101, DATEADD(DAY, -20, CAST(GETDATE() AS DATE)), 'CD', 5000),
    (101, DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), 'CW', 2000),
    (102, DATEADD(DAY, -15, CAST(GETDATE() AS DATE)), 'CD', 9000),
    (103, DATEADD(DAY, -7, CAST(GETDATE() AS DATE)), 'CW', 1200),
    (106, DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), 'CD', 7000);
GO

INSERT INTO dbo.UDF_EMPLOYEE_PAY
    (EMP_ID, EMP_NAME, BASIC_PAY, ALLOWANCE, PF_AMOUNT, TAX_AMOUNT)
VALUES
    (1, 'Kiran', 30000, 8000, 2500, 3500),
    (2, 'Meena', 42000, 10000, 4200, 6200),
    (3, 'Rohit', 25000, 5000, 2000, 2500);
GO

INSERT INTO dbo.UDF_MOVIE_CUSTOMER
    (SEAT_NO, CUSTOMER_NAME, EMAIL, PHONE_NO)
VALUES
    ('A1', 'Usman', 'usman@example.com', '9000000001'),
    ('A2', 'Leela', 'leela@example.com', '9000000002');
GO

CREATE FUNCTION dbo.udf_get_customer_balance_lesson
(
    @AccountID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Balance MONEY;

    SELECT @Balance = ISNULL(CBAL, 0)
    FROM dbo.UDF_ACCOUNT_MASTER
    WHERE ACID = @AccountID;

    RETURN ISNULL(@Balance, 0);
END;
GO

CREATE FUNCTION dbo.udf_calculate_net_salary_lesson
(
    @BasicPay MONEY,
    @Allowance MONEY,
    @PfAmount MONEY,
    @TaxAmount MONEY
)
RETURNS MONEY
AS
BEGIN
    RETURN (@BasicPay + @Allowance) - (@PfAmount + @TaxAmount);
END;
GO

CREATE FUNCTION dbo.udf_get_accounts_by_branch_lesson
(
    @BranchID CHAR(3)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ACID, CUST_NAME, BRID, CITY, CBAL, STATUS
    FROM dbo.UDF_ACCOUNT_MASTER
    WHERE BRID = @BranchID
);
GO

CREATE FUNCTION dbo.udf_get_account_snapshot_lesson
(
    @AccountID INT
)
RETURNS @Result TABLE
(
    ACID INT,
    CUST_NAME VARCHAR(50),
    BRID CHAR(3),
    CBAL MONEY,
    TXN_COUNT INT
)
AS
BEGIN
    INSERT INTO @Result
        (ACID, CUST_NAME, BRID, CBAL, TXN_COUNT)
    SELECT
        a.ACID,
        a.CUST_NAME,
        a.BRID,
        ISNULL(a.CBAL, 0),
        COUNT(t.TXN_ID)
    FROM dbo.UDF_ACCOUNT_MASTER AS a
    LEFT JOIN dbo.UDF_TXN_MASTER AS t
        ON a.ACID = t.ACID
    WHERE a.ACID = @AccountID
    GROUP BY a.ACID, a.CUST_NAME, a.BRID, a.CBAL;

    RETURN;
END;
GO

CREATE FUNCTION dbo.udf_get_next_seat_lesson()
RETURNS VARCHAR(3)
AS
BEGIN
    DECLARE @LastSeat VARCHAR(3);
    DECLARE @LastRow CHAR(1);
    DECLARE @LastNumber INT;
    DECLARE @NextSeat VARCHAR(3);

    SELECT TOP (1) @LastSeat = SEAT_NO
    FROM dbo.UDF_MOVIE_CUSTOMER
    ORDER BY CUSTOMER_ID DESC;

    IF @LastSeat IS NULL
        SET @NextSeat = 'A1';
    ELSE
    BEGIN
        SET @LastRow = LEFT(@LastSeat, 1);
        SET @LastNumber = CAST(SUBSTRING(@LastSeat, 2, 2) AS INT);

        IF @LastNumber < 12
            SET @NextSeat = @LastRow + CAST(@LastNumber + 1 AS VARCHAR(2));
        ELSE
            SET @NextSeat = CHAR(ASCII(@LastRow) + 1) + '1';
    END;

    RETURN @NextSeat;
END;
GO

CREATE PROCEDURE dbo.usp_udf_insert_movie_customer_lesson
    @CustomerName VARCHAR(50),
    @Email VARCHAR(80),
    @PhoneNo VARCHAR(20)
AS
BEGIN
    INSERT INTO dbo.UDF_MOVIE_CUSTOMER
        (SEAT_NO, CUSTOMER_NAME, EMAIL, PHONE_NO)
    VALUES
        (dbo.udf_get_next_seat_lesson(), @CustomerName, @Email, @PhoneNo);
END;
GO

SELECT 'UDF combined setup completed' AS SETUP_STATUS;
SELECT * FROM dbo.UDF_ACCOUNT_MASTER;
SELECT * FROM dbo.UDF_EMPLOYEE_PAY;
SELECT * FROM dbo.UDF_MOVIE_CUSTOMER;
GO
