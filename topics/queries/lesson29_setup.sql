USE company;
GO

/*
Lesson 29 setup

Run this file first.
It creates a lesson-specific table with data designed for:
- NULLIF comparisons between CBAL and UBAL
- BETWEEN operator practice
- CASE statement practice
- subquery practice where multiple customers share the highest balance
*/

DROP TABLE IF EXISTS dbo.AMASTER_L29;
GO

CREATE TABLE dbo.AMASTER_L29
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

INSERT INTO dbo.AMASTER_L29 (ACID, NAME, ADDRESS, BRID, PID, DOO, CBAL, UBAL, STATUS)
VALUES
    (1,  'John Doe',      '123 Main St',      'NYC', '01', '2010-01-15',  5000.00,  5000.00, 'A'),
    (2,  'Jane Smith',    '456 Elm St',       'LA',  '02', '2011-06-20',  7500.00,  7600.00, 'A'),
    (3,  'Bob Johnson',   '789 Oak St',       'CHI', '03', '2012-09-10', 12000.00, 12000.00, 'A'),
    (4,  'Alice Brown',   '321 Pine St',      'HOU', '04', '2013-12-05', 18000.00, 20000.00, 'A'),
    (5,  'Charlie Davis', '654 Cedar St',     'PH',  '05', '2014-03-18', 22000.00, 22000.00, 'A'),
    (6,  'Eve Wilson',    '987 Spruce St',    'NYC', '06', '2015-07-01', 35000.00, 35500.00, 'A'),
    (7,  'Frank Miller',  '246 Maple St',     'LA',  '07', '2016-11-23', 50000.00, 50000.00, 'A'),
    (8,  'Grace Lee',     '135 Birch St',     'HOU', '08', '2017-04-14', 50000.00, 52000.00, 'A'),
    (9,  'Hank Green',    '864 Walnut St',    'CHI', '09', '2018-08-30',  9500.00,  9500.00, 'A'),
    (10, 'Ivy White',     '753 Chestnut St',  'PH',  '10', '2019-01-09', 15000.00, 15000.00, 'A'),
    (11, 'Karen Gray',    '753 Pine St',      'NYC', '11', '2020-05-21', 50000.00, 50000.00, 'A'),
    (12, 'Leo King',      '321 Lake St',      'LA',  '12', '2021-10-02',  8000.00,  8300.00, 'A');
GO

SELECT *
FROM dbo.AMASTER_L29;
