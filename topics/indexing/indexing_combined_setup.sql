USE company;
GO

/*
Indexing combined setup

Run this file before:
- indexing_combined_revision_notebook.md
- indexing_combined_practice.sql

It creates small demo tables for:
- heap table behavior
- clustered index behavior
- nonclustered indexes
- unique constraints/indexes
- execution plan practice
- covered index practice
*/

DROP TABLE IF EXISTS dbo.IDX_EMP_HEAP;
DROP TABLE IF EXISTS dbo.IDX_EMP_CLUSTERED;
DROP TABLE IF EXISTS dbo.IDX_ACCOUNT_MASTER;
GO

CREATE TABLE dbo.IDX_EMP_HEAP
(
    EMP_ID INT NOT NULL,
    EMP_NAME VARCHAR(50) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    GENDER CHAR(1) NOT NULL,
    SALARY MONEY NOT NULL
);
GO

CREATE TABLE dbo.IDX_EMP_CLUSTERED
(
    EMP_ID INT NOT NULL PRIMARY KEY,
    EMP_NAME VARCHAR(50) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    GENDER CHAR(1) NOT NULL,
    SALARY MONEY NOT NULL
);
GO

CREATE TABLE dbo.IDX_ACCOUNT_MASTER
(
    ACID INT NOT NULL PRIMARY KEY,
    CUST_NAME VARCHAR(50) NOT NULL,
    BRID CHAR(3) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    CBAL MONEY NOT NULL,
    STATUS CHAR(1) NOT NULL,
    EMAIL VARCHAR(80) NULL,
    CONSTRAINT UQ_IDX_ACCOUNT_EMAIL UNIQUE (EMAIL)
);
GO

INSERT INTO dbo.IDX_EMP_HEAP
    (EMP_ID, EMP_NAME, CITY, GENDER, SALARY)
VALUES
    (124, 'John', 'Chennai', 'M', 25000),
    (98, 'Mary', 'Chennai', 'F', 32000),
    (87, 'Mahi', 'Hyderabad', 'M', 41000),
    (19, 'Vinit', 'Bengaluru', 'M', 28000),
    (55, 'Harry', 'Hyderabad', 'M', 36000),
    (33, 'Asha', 'Mumbai', 'F', 30000),
    (12, 'Bhavya', 'Bengaluru', 'F', 45000),
    (77, 'Kiran', 'Chennai', 'M', 39000);
GO

INSERT INTO dbo.IDX_EMP_CLUSTERED
    (EMP_ID, EMP_NAME, CITY, GENDER, SALARY)
VALUES
    (124, 'John', 'Chennai', 'M', 25000),
    (98, 'Mary', 'Chennai', 'F', 32000),
    (87, 'Mahi', 'Hyderabad', 'M', 41000),
    (19, 'Vinit', 'Bengaluru', 'M', 28000),
    (55, 'Harry', 'Hyderabad', 'M', 36000),
    (33, 'Asha', 'Mumbai', 'F', 30000),
    (12, 'Bhavya', 'Bengaluru', 'F', 45000),
    (77, 'Kiran', 'Chennai', 'M', 39000);
GO

INSERT INTO dbo.IDX_ACCOUNT_MASTER
    (ACID, CUST_NAME, BRID, CITY, CBAL, STATUS, EMAIL)
VALUES
    (101, 'Anil', 'BR1', 'Hyderabad', 15000, 'A', 'anil@example.com'),
    (102, 'Bhavya', 'BR2', 'Bengaluru', 22000, 'A', 'bhavya@example.com'),
    (103, 'Charan', 'BR1', 'Hyderabad', 8000, 'A', 'charan@example.com'),
    (104, 'Deepa', 'BR3', 'Mumbai', 500, 'I', 'deepa@example.com'),
    (105, 'Esha', 'BR2', 'Bengaluru', 35000, 'A', 'esha@example.com'),
    (106, 'Farhan', 'BR3', 'Mumbai', 41000, 'A', 'farhan@example.com'),
    (107, 'Gita', 'BR1', 'Hyderabad', 12000, 'A', 'gita@example.com'),
    (108, 'Harish', 'BR4', 'Chennai', 56000, 'A', 'harish@example.com');
GO

SELECT 'Indexing combined setup completed' AS SETUP_STATUS;
SELECT * FROM dbo.IDX_EMP_HEAP;
SELECT * FROM dbo.IDX_EMP_CLUSTERED;
SELECT * FROM dbo.IDX_ACCOUNT_MASTER;
GO

