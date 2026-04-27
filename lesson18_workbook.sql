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

7. COUNT(*) returns the number of rows.
   Example:
   SELECT COUNT(*) AS TOTAL_CUSTOMERS
   FROM AMASTER;

8. SUM(column) returns the total of a numeric column.
   Example:
   SELECT SUM(CBAL) AS TOTAL_BALANCE
   FROM AMASTER;

9. MIN, MAX, and AVG work on numeric or date values.
   Example:
   SELECT MIN(CBAL) AS MIN_BALANCE,
          MAX(CBAL) AS MAX_BALANCE,
          AVG(CBAL) AS AVG_BALANCE
   FROM AMASTER;

10. WHERE filters rows before aggregate functions are calculated.
    Example:
    SELECT COUNT(*) AS NYC_CUSTOMERS
    FROM AMASTER
    WHERE BRID = 'NYC';

11. IN is a shortcut for multiple OR conditions.
    Example:
    SELECT COUNT(*) AS CUSTOMER_COUNT
    FROM AMASTER
    WHERE BRID IN ('NYC', 'LA', 'HOU');

12. Basic execution order for these queries:
    FROM
    WHERE
    AGGREGATE
    SELECT

========================================
PRACTICE QUESTIONS
Write your answer below each question.
========================================
*/

-- Q1. Show NAME and CBAL, and print a single extra column
-- that says NAME has balance CBAL using CAST.


-- Q2. Show ACID, NAME, and DOO.
-- Also show DOO converted using CONVERT with style 101.


-- Q3. Show ACID, NAME, and DOO.
-- Also show DOO converted using CONVERT with style 103.


-- Q4. Count all customers in AMASTER.


-- Q5. Count customers only in branch 'NYC'.


-- Q6. Count customers in branch 'NYC' or 'LA'.


-- Q7. Count customers using IN for branches 'NYC', 'LA', and 'HOU'.


-- Q8. Find the total of CBAL for all customers.


-- Q9. Find the total of CBAL only for branch 'HOU'.


-- Q10. Find the minimum, maximum, and average CBAL for all customers.


-- Q11. Find the minimum, maximum, and average CBAL for branch 'LA'.


-- Q12. Count customers and find total balance in one single query.


-- Q13. Count customers and find total balance only for branch 'NYC'.


-- Q14. Show the earliest and latest DOO in the table.


-- Q15. Show NAME as [Customer Name] and
-- CONVERT(VARCHAR(30), DOO, 103) as [Open Date].


/*
OPTIONAL CHALLENGE

1. Write one query to show:
   total customers, total balance, minimum balance, maximum balance, average balance
   for branch 'LA'.

2. Count customers in 'NYC', 'LA', or 'PH' using IN.

3. Show DOO in two different styles in the same query.

4. Write in comments:
   execution order is FROM -> WHERE -> AGGREGATE -> SELECT
*/
