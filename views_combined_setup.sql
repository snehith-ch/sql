USE company;
GO

/*
Combined Views setup for transcript set:
- 2_transcript.txt
- 3_transcript.txt
- 4_transcript.txt
- 05 SQL Server - Views Part4 - Schemas and Indexed Views.txt

Run this file first.
It creates lesson-specific objects for:
- basic view creation / alter / drop / sp_helptext practice
- updatable vs non-updatable views
- filtered views, current-year views, view-on-view, and join-with-view practice
- schema demo objects
- function vs procedure comparison points used in the transcript
- schemabinding / encryption / check option / indexed view exercises
*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'reporting_lvw'
)
    EXEC('CREATE SCHEMA reporting_lvw');
GO

DROP VIEW IF EXISTS reporting_lvw.vw_br2_accounts_lvw;
DROP VIEW IF EXISTS dbo.vw_active_accounts_lvw;
DROP VIEW IF EXISTS dbo.vw_br1_accounts_lvw;
DROP VIEW IF EXISTS dbo.vw_balance_labels_lvw;
DROP VIEW IF EXISTS dbo.vw_no_txn_last_6_months_lvw;
DROP VIEW IF EXISTS dbo.vw_branch_summary_lvw;
DROP VIEW IF EXISTS dbo.vw_current_year_txn_lvw;
DROP VIEW IF EXISTS dbo.vw_current_year_account_txn_lvw;
DROP VIEW IF EXISTS dbo.vw_current_year_branch_amount_lvw;
DROP VIEW IF EXISTS dbo.vw_active_accounts_schema_lvw;
DROP VIEW IF EXISTS dbo.vw_br1_accounts_encrypted_lvw;
DROP VIEW IF EXISTS dbo.vw_br1_accounts_check_lvw;
DROP VIEW IF EXISTS dbo.vw_branch_balance_indexed_lvw;
GO

DROP PROCEDURE IF EXISTS dbo.usp_GetActiveAccounts_LVW;
DROP FUNCTION IF EXISTS dbo.fn_ActiveAccounts_LVW;
DROP TABLE IF EXISTS dbo.TRANSACTION_MASTER_VW;
DROP TABLE IF EXISTS dbo.ACCOUNT_MASTER_VW;
DROP TABLE IF EXISTS dbo.BRANCH_MASTER_VW;
GO

CREATE TABLE dbo.BRANCH_MASTER_VW
(
    BRID          CHAR(3) PRIMARY KEY,
    BRANCH_NAME   VARCHAR(50) NOT NULL,
    BRANCH_CITY   VARCHAR(30) NOT NULL,
    MANAGER_NAME  VARCHAR(40) NOT NULL
);
GO

CREATE TABLE dbo.ACCOUNT_MASTER_VW
(
    ACID          INT PRIMARY KEY,
    CUST_NAME     VARCHAR(50) NOT NULL,
    CITY          VARCHAR(30) NOT NULL,
    BRID          CHAR(3) NOT NULL,
    ACCOUNT_TYPE  VARCHAR(20) NOT NULL,
    DOO           DATE NOT NULL,
    STATUS        CHAR(1) NOT NULL,
    CBAL          DECIMAL(18, 2) NOT NULL,
    EMAIL         VARCHAR(60) NULL,
    RMK           VARCHAR(100) NULL,
    CONSTRAINT FK_ACCOUNT_MASTER_VW_BRANCH
        FOREIGN KEY (BRID) REFERENCES dbo.BRANCH_MASTER_VW (BRID)
);
GO

CREATE TABLE dbo.TRANSACTION_MASTER_VW
(
    TXNID      INT PRIMARY KEY,
    ACID       INT NOT NULL,
    TXN_DATE   DATE NOT NULL,
    TXN_TYPE   VARCHAR(30) NOT NULL,
    AMOUNT     DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_TRANSACTION_MASTER_VW_ACCOUNT
        FOREIGN KEY (ACID) REFERENCES dbo.ACCOUNT_MASTER_VW (ACID)
);
GO

INSERT INTO dbo.BRANCH_MASTER_VW (BRID, BRANCH_NAME, BRANCH_CITY, MANAGER_NAME)
VALUES
    ('BR1', 'Hyderabad Main', 'Hyderabad', 'Ramesh'),
    ('BR2', 'Bengaluru Tech', 'Bengaluru', 'Sowmya'),
    ('BR3', 'Mumbai Central', 'Mumbai', 'Imran'),
    ('BR4', 'Chennai South', 'Chennai', 'Kavitha');
GO

INSERT INTO dbo.ACCOUNT_MASTER_VW
(
    ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL, RMK
)
VALUES
    (101, 'Anil',   'Hyderabad', 'BR1', 'SAVINGS', DATEADD(YEAR,  -3, CAST(GETDATE() AS DATE)), 'A', 12000.00, 'anil@example.com',   NULL),
    (102, 'Bhavya', 'Hyderabad', 'BR1', 'CURRENT', DATEADD(YEAR,  -2, CAST(GETDATE() AS DATE)), 'A', 34000.00, 'bhavya@example.com', 'VIP'),
    (103, 'Charan', 'Bengaluru', 'BR2', 'SAVINGS', DATEADD(YEAR,  -2, CAST(GETDATE() AS DATE)), 'A',  8000.00, 'charan@example.com', NULL),
    (104, 'Deepa',  'Mumbai',    'BR3', 'SAVINGS', DATEADD(MONTH, -20, CAST(GETDATE() AS DATE)), 'A', 56000.00, 'deepa@example.com',  NULL),
    (105, 'Esha',   'Chennai',   'BR4', 'CURRENT', DATEADD(MONTH, -18, CAST(GETDATE() AS DATE)), 'I', 15000.00, 'esha@example.com',   'Dormant'),
    (106, 'Farhan', 'Mumbai',    'BR3', 'SAVINGS', DATEADD(MONTH, -12, CAST(GETDATE() AS DATE)), 'A', 28000.00, 'farhan@example.com', NULL),
    (107, 'Gita',   'Bengaluru', 'BR2', 'SAVINGS', DATEADD(MONTH, -10, CAST(GETDATE() AS DATE)), 'A',  4500.00, NULL,                 NULL),
    (108, 'Harish', 'Hyderabad', 'BR1', 'CURRENT', DATEADD(MONTH,  -6, CAST(GETDATE() AS DATE)), 'A', 91000.00, 'harish@example.com', 'Corporate'),
    (109, 'Ishita', 'Chennai',   'BR4', 'SAVINGS', DATEADD(MONTH,  -4, CAST(GETDATE() AS DATE)), 'A',  6300.00, 'ishita@example.com', NULL),
    (110, 'Jai',    'Pune',      'BR3', 'SAVINGS', DATEADD(MONTH,  -3, CAST(GETDATE() AS DATE)), 'A', 22000.00, NULL,                 NULL),
    (111, 'Kavya',  'Hyderabad', 'BR1', 'SAVINGS', DATEADD(MONTH,  -2, CAST(GETDATE() AS DATE)), 'A', 18500.00, 'kavya@example.com',  NULL),
    (112, 'Lokesh', 'Bengaluru', 'BR2', 'CURRENT', DATEADD(MONTH,  -1, CAST(GETDATE() AS DATE)), 'A', 40000.00, 'lokesh@example.com', 'High balance');
GO

INSERT INTO dbo.TRANSACTION_MASTER_VW (TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT)
VALUES
    (1001, 101, DATEADD(DAY,   -10, CAST(GETDATE() AS DATE)), 'Cash Deposit',   5000.00),
    (1002, 101, DATEADD(MONTH,  -2, CAST(GETDATE() AS DATE)), 'UPI Debit',       1500.00),
    (1003, 102, DATEADD(MONTH,  -7, CAST(GETDATE() AS DATE)), 'Cash Deposit',    4000.00),
    (1004, 103, DATEADD(DAY,   -20, CAST(GETDATE() AS DATE)), 'ATM Withdrawal',   700.00),
    (1005, 104, DATEADD(YEAR,   -1, CAST(GETDATE() AS DATE)), 'Cash Deposit',   10000.00),
    (1006, 104, DATEADD(DAY,    -3, CAST(GETDATE() AS DATE)), 'Cash Deposit',    2000.00),
    (1007, 105, DATEADD(MONTH,  -8, CAST(GETDATE() AS DATE)), 'UPI Credit',       900.00),
    (1008, 106, DATEADD(MONTH,  -1, CAST(GETDATE() AS DATE)), 'Cash Deposit',    3500.00),
    (1009, 107, DATEADD(YEAR,   -2, CAST(GETDATE() AS DATE)), 'Cash Withdrawal',  500.00),
    (1010, 108, DATEADD(DAY,    -1, CAST(GETDATE() AS DATE)), 'NEFT Credit',    25000.00),
    (1011, 110, DATEADD(MONTH,  -9, CAST(GETDATE() AS DATE)), 'Cash Deposit',    1000.00),
    (1012, 111, DATEADD(MONTH,  -5, CAST(GETDATE() AS DATE)), 'ATM Withdrawal',   800.00),
    (1013, 112, DATEADD(MONTH, -11, CAST(GETDATE() AS DATE)), 'Cash Deposit',    6500.00),
    (1014, 112, DATEADD(DAY,   -15, CAST(GETDATE() AS DATE)), 'IMPS Debit',      1200.00);
GO

CREATE FUNCTION dbo.fn_ActiveAccounts_LVW ()
RETURNS TABLE
AS
RETURN
(
    SELECT ACID, CUST_NAME, BRID, CBAL, STATUS
    FROM dbo.ACCOUNT_MASTER_VW
    WHERE STATUS = 'A'
);
GO

CREATE PROCEDURE dbo.usp_GetActiveAccounts_LVW
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ACID, CUST_NAME, BRID, CBAL, STATUS
    FROM dbo.ACCOUNT_MASTER_VW
    WHERE STATUS = 'A';
END;
GO

SELECT * FROM dbo.BRANCH_MASTER_VW;
SELECT * FROM dbo.ACCOUNT_MASTER_VW;
SELECT * FROM dbo.TRANSACTION_MASTER_VW;
