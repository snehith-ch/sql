USE company;
GO

/*
Lesson 18 Workbook: Convert Styles and Aggregate Functions
Table used: AMASTER

Run practice.sql first if AMASTER does not exist.

========================================
QUICK NOTES
========================================
1. CAST and CONVERT are used to change data types.

2. CAST syntax:
   CAST(column_name AS data_type)

3. CONVERT syntax:
   CONVERT(data_type, column_name, style_number)

4. CAST is commonly used to convert one data type to another.
   Example:
   SELECT NAME + ' has balance ' + CAST(CBAL AS VARCHAR(30)) AS BALANCE_INFO
   FROM AMASTER;

5. CONVERT can also change date display styles in SQL Server.
   Example:
   SELECT CONVERT(VARCHAR(30), DOO, 103) AS OPEN_DATE
   FROM AMASTER;

6. CAST does not use style numbers.
   CONVERT can use style numbers, especially for date and time formatting.

7. CAST is ANSI-standard and works across many RDBMS tools.
   CONVERT is mainly SQL Server-specific.

8. COUNT(*) returns the number of rows.
   Example:
   SELECT COUNT(*) AS TOTAL_CUSTOMERS
   FROM AMASTER;

9. SUM(column) returns the total of a numeric column.
   Example:
   SELECT SUM(CBAL) AS TOTAL_BALANCE
   FROM AMASTER;

10. MIN, MAX, and AVG work on numeric or date values.
   Example:
   SELECT MIN(CBAL) AS MIN_BALANCE,
          MAX(CBAL) AS MAX_BALANCE,
          AVG(CBAL) AS AVG_BALANCE
   FROM AMASTER;

11. WHERE filters rows before aggregate functions are calculated.
    Example:
    SELECT COUNT(*) AS NYC_CUSTOMERS
    FROM AMASTER
    WHERE BRID = 'NYC';

12. IN is a shortcut for multiple OR conditions.
    Example:
    SELECT COUNT(*) AS CUSTOMER_COUNT
    FROM AMASTER
    WHERE BRID IN ('NYC', 'LA', 'HOU');

13. Basic execution order for these queries:
    FROM
    WHERE
    AGGREGATE
    SELECT

========================================
PRACTICE QUESTIONS
Write your answer below each question.
========================================
*/
select * from AMASTER
-- Q1. Show NAME and CBAL, and print a single extra column
-- that says NAME has balance CBAL using CAST.
select NAME, CBAL, NAME + ' has balance ' + CAST(CBAL as VARCHAR(30)) as BALANCE_INFO from AMASTER 

-- Q2. Show ACID, NAME, and DOO.
-- Also show DOO converted using CONVERT with style 101.
select ACID, NAME, CONVERT(VARCHAR(30),DOO, 101) as DOO from AMASTER

-- Q3. Show ACID, NAME, and DOO.
-- Also show DOO converted using CONVERT with style 103.
SELECT ACID, NAME, CONVERT(VARCHAR(30), DOO, 103)as DOO from AMASTER

-- Q4. Count all customers in AMASTER.
select count(*) as TOTAL_CUSTOMERS from AMASTER

-- Q5. Count customers only in branch 'NYC'.
select count(BRID) as BRID_NYC from AMASTER where BRID='NYC'

-- Q6. Count customers in branch 'NYC' or 'LA'.
SELECT COUNT(BRID) AS BRID FROM AMASTER WHERE BRID IN('NYC', 'LA')

-- Q7. Count customers using IN for branches 'NYC', 'LA', and 'HOU'.
select COUNT(BRID) as BRID from AMASTER where BRID IN ('NYC', 'LA', 'HOU')

-- Q8. Find the total of CBAL for all customers.
select sum(CBAL) AS TOTAL_BALANCE from AMASTER

-- Q9. Find the total of CBAL only for branch 'HOU'.
SELECT SUM(CBAL) AS TOTAL_BAL FROM AMASTER WHERE BRID='HOU'

-- Q10. Find the minimum, maximum, and average CBAL for all customers.
select MIN(CBAL) AS MIN, MAX(CBAL) AS MAX, AVG(CBAL) AS AVG FROM AMASTER

-- Q11. Find the minimum, maximum, and average CBAL for branch 'LA'.
select MIN(CBAL) AS MIN, MAX(CBAL) AS MAX, AVG(CBAL) AS AVG FROM AMASTER WHERE BRID='LA'

-- Q12. Count customers and find total balance in one single query.
select COUNT(*) AS TOTAL_CUSTOMERS, SUM(CBAL) AS TOTAL_BALANCE from AMASTER

-- Q13. Count customers and find total balance only for branch 'NYC'.
select COUNT(*) AS TOTAL_CUSTOMERS, SUM(CBAL) AS TOTAL_BALANCE from AMASTER where BRID='NYC'

-- Q14. Show the earliest and latest DOO in the table.
select MIN(DOO) AS MIN, MAX(DOO) AS MAX from AMASTER

-- Q15. Show NAME as [Customer Name] and
-- CONVERT(VARCHAR(30), DOO, 103) as [Open Date].
select NAME as [Customer Name], CONVERT(VARCHAR(30), DOO, 103) as [Open Date] from AMASTER

-- Q16. Show one column that prints:
-- USD <CBAL>
-- for every row using CONVERT.


-- Q17. Show DOO converted using CONVERT without a style number.


-- Q18. Count all customers and give the output column an alias with spaces:
-- [Total Customers]

/*
OPTIONAL CHALLENGE

1. Write one query to show:
   total customers, total balance, minimum balance, maximum balance, average balance
   for branch 'LA'.
select COUNT(BRID) AS TOTAL_CUSTOMERS, SUM(CBAL) AS TOTAL_BALANCE, MIN(CBAL) AS MINIMUM_BALANCE, MAX(CBAL) AS MAX_BALANCE, AVG(CBAL) AS AVG_BALANCE FROM AMASTER WHERE BRID='LA'

2. Count customers in 'NYC', 'LA', or 'PH' using IN.
select COUNT(*) AS TOTAL_CUSTOMERS from AMASTER where BRID IN ('NYC', 'LA', 'PH')
3. Show DOO in two different styles in the same query.
select NAME, CONVERT(varchar(30), DOO, 101) as DOO_101, CONVERT(VARCHAR(30), DOO, 103) as DOO_103 from AMASTER

4. Write in comments:
   execution order is FROM -> WHERE -> AGGREGATE -> SELECT
select 'execution order is FROM -> WHERE -> AGGREGATE -> SELECT' as comments from AMASTER

5. Write in comments:
   when CAST is preferred and when CONVERT is preferred.

*/
