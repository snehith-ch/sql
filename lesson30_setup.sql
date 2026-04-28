USE company;
GO

/*
Lesson 30 setup

Run this file first.
It creates lesson-specific tables for:
- normal subqueries in SELECT and WHERE
- nested subqueries for second highest / nth highest
- correlated subqueries
- EXISTS and NOT EXISTS
- salary-vs-department-average interview practice
*/

DROP TABLE IF EXISTS dbo.TMASTER_L30;
DROP TABLE IF EXISTS dbo.AMASTER_L30;
DROP TABLE IF EXISTS dbo.EMPLOYEE_L30;
GO

CREATE TABLE dbo.AMASTER_L30
(
    ACID    INT PRIMARY KEY,
    NAME    VARCHAR(50) NOT NULL,
    ADDRESS VARCHAR(50) NOT NULL,
    BRID    CHAR(3) NOT NULL,
    PID     CHAR(2) NOT NULL,
    DOO     DATE NOT NULL,
    CBAL    DECIMAL(18, 2) NOT NULL,
    UBAL    DECIMAL(18, 2) NOT NULL,
    STATUS  CHAR(1) NOT NULL
);
GO

CREATE TABLE dbo.TMASTER_L30
(
    TXNID     INT PRIMARY KEY,
    ACID      INT NOT NULL,
    TXN_DATE  DATE NOT NULL,
    TXN_TYPE  VARCHAR(20) NOT NULL,
    AMOUNT    DECIMAL(18, 2) NOT NULL
);
GO

CREATE TABLE dbo.EMPLOYEE_L30
(
    EMPID            INT PRIMARY KEY,
    EMPLOYEE_NAME    VARCHAR(50) NOT NULL,
    DEPARTMENT_NAME  VARCHAR(30) NOT NULL,
    SALARY           DECIMAL(18, 2) NOT NULL
);
GO

INSERT INTO dbo.AMASTER_L30 (ACID, NAME, ADDRESS, BRID, PID, DOO, CBAL, UBAL, STATUS)
VALUES
    (1,  'John Doe',      '123 Main St',      'NYC', '01', '2020-01-15', 10000.00, 10000.00, 'A'),
    (2,  'Jane Smith',    '456 Elm St',       'LA',  '02', '2020-02-10', 20000.00, 20500.00, 'A'),
    (3,  'Bob Johnson',   '789 Oak St',       'CHI', '03', '2020-03-18', 30000.00, 30000.00, 'A'),
    (4,  'Alice Brown',   '321 Pine St',      'HOU', '04', '2020-04-05', 40000.00, 42000.00, 'A'),
    (5,  'Charlie Davis', '654 Cedar St',     'PH',  '05', '2020-05-21', 50000.00, 50000.00, 'A'),
    (6,  'Eve Wilson',    '987 Spruce St',    'NYC', '06', '2020-06-30', 50000.00, 52000.00, 'A'),
    (7,  'Frank Miller',  '246 Maple St',     'LA',  '07', '2020-07-11', 45000.00, 45000.00, 'A'),
    (8,  'Grace Lee',     '135 Birch St',     'HOU', '08', '2020-08-22', 40000.00, 40500.00, 'A'),
    (9,  'Hank Green',    '864 Walnut St',    'CHI', '09', '2020-09-09', 35000.00, 35000.00, 'A'),
    (10, 'Ivy White',     '753 Chestnut St',  'PH',  '10', '2020-10-14', 25000.00, 25000.00, 'A'),
    (11, 'Karen Gray',    '753 Pine St',      'NYC', '11', '2020-11-03', 15000.00, 15000.00, 'A'),
    (12, 'Leo King',      '321 Lake St',      'LA',  '12', '2020-12-19', 45000.00, 47000.00, 'A');
GO

INSERT INTO dbo.TMASTER_L30 (TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT)
VALUES
    (1,  1,  '2021-01-10', 'Cash Deposit',    1000.00),
    (2,  1,  '2021-01-11', 'Cash Withdrawal',  500.00),
    (3,  2,  '2021-01-12', 'Cash Deposit',    3000.00),
    (4,  4,  '2021-01-15', 'Cash Withdrawal', 2000.00),
    (5,  5,  '2021-01-18', 'Cash Deposit',    2500.00),
    (6,  5,  '2021-01-19', 'Cash Deposit',    4500.00),
    (7,  7,  '2021-01-22', 'Cash Withdrawal', 1500.00),
    (8,  10, '2021-01-25', 'Cash Deposit',    3200.00),
    (9,  10, '2021-01-26', 'Cash Withdrawal', 1200.00),
    (10, 12, '2021-01-28', 'Cash Deposit',    2800.00);
GO

INSERT INTO dbo.EMPLOYEE_L30 (EMPID, EMPLOYEE_NAME, DEPARTMENT_NAME, SALARY)
VALUES
    (1, 'John',   'HR',    10000.00),
    (2, 'Girish', 'HR',    12000.00),
    (3, 'Manath', 'Sales',  8000.00),
    (4, 'Salman', 'Sales', 14000.00),
    (5, 'Ratan',  'IT',     9000.00),
    (6, 'Peter',  'IT',    11000.00),
    (7, 'Anita',  'HR',     9000.00),
    (8, 'Neha',   'Sales', 15000.00);
GO

SELECT * FROM dbo.AMASTER_L30;
SELECT * FROM dbo.TMASTER_L30;
SELECT * FROM dbo.EMPLOYEE_L30;
