USE company;
GO

/*
Lesson 17 Workbook: Basic SQL Retrieval
Table used: AMASTER

Run practice.sql first if AMASTER does not exist.

========================================
QUICK NOTES
========================================
1. SELECT is used to choose columns.
   Example:
   SELECT ACID, NAME FROM AMASTER;

2. * means all columns.
   Example:
   SELECT * FROM AMASTER;

3. WHERE is used to filter rows.
   Example:
   SELECT * FROM AMASTER
   WHERE BRID = 'NYC';

4. ORDER BY is used to sort the result.
   ASC  = ascending
   DESC = descending
   Example:
   SELECT ACID, NAME, CBAL
   FROM AMASTER
   ORDER BY CBAL DESC;

5. You can filter columns and rows together.
   Example:
   SELECT ACID, NAME, CBAL
   FROM AMASTER
   WHERE BRID = 'LA';

6. Constants can be printed in a query.
   Example:
   SELECT NAME, 'USD' AS CURRENCY
   FROM AMASTER;

7. Aliases rename output columns.
   Example:
   SELECT NAME AS CUSTOMER_NAME, CBAL AS CLEAR_BALANCE
   FROM AMASTER;

8. Concatenation joins strings using + in SQL Server.
   Example:
   SELECT NAME + ' is an account holder' AS ACCOUNT_NOTE
   FROM AMASTER;

9. If you want to join text with a numeric column, convert the number first.
   Example:
   SELECT NAME + ' has balance ' + CAST(CBAL AS VARCHAR(30)) AS BALANCE_INFO
   FROM AMASTER;

10. Typical order of clauses:
    SELECT
    FROM
    WHERE
    ORDER BY

========================================
PRACTICE QUESTIONS
Write your answer below each question.
========================================
*/

-- Q1. Show all columns and all rows from AMASTER.
select * from AMASTER

-- Q2. Show only ACID, NAME, and CBAL for all customers.
select ACID, NAME, CBAL from AMASTER

-- Q3. Show all columns for customers whose BRID is 'NYC'.
select * from AMASTER where BRID = 'NYC'

-- Q4. Show ACID, NAME, and CBAL for customers whose BRID is 'LA'.
select ACID, NAME, CBAL from AMASTER where BRID='LA'

-- Q5. Show all columns for customers whose BRID is 'NYC'
-- and whose CBAL is greater than 5000.
select * from AMASTER where BRID='NYC' and CBAL>5000

-- Q6. Show ACID, NAME, and CBAL for all customers
-- sorted by NAME in descending order.
select ACID, NAME, CBAL from AMASTER order by NAME desc

-- Q7. Show NAME and a constant column 'USD' with alias CURRENCY.
select name, 'USD' as currency from AMASTER

-- Q8. Show NAME with alias CUSTOMER_NAME and CBAL with alias CLEAR_BALANCE.
select name as CUSTOMER_NAME, CBAL as CLEAR_BALANCE from AMASTER

-- Q9. Show a sentence like:
-- John Doe is an account holder
-- Use NAME and concatenation.
select name + ' is an account holder' from AMASTER

-- Q10. Show a sentence like:
-- John Doe has balance 1000.00
-- Use NAME, text, and CBAL.
-- Hint: convert CBAL before concatenating.
select name + ' has balance ' + cast(cbal as varchar(30)) from AMASTER


-- OPTIONAL CHALLENGE

--1. Show all rows where BRID is 'PH ' or 'HOU'.
select * from amaster where brid='ph' or brid='hou'

--2. Show all rows sorted by CBAL from highest to lowest.
select * from AMASTER order by CBAL desc

--3. Show NAME and STATUS only for customers whose STATUS is 'A'.
select name, status from AMASTER where status='a'
--When you finish, send me your queries and I will review them one by one.

/*
========================================
EXTRA TOPICS FROM THE TRANSCRIPT
These were discussed in the class and are worth practicing too.
========================================
*/

-- Q11. Show ACID, NAME, and CBAL for all customers
-- sorted by NAME in ascending order.
select ACID, NAME, CBAL from AMASTER ORDER BY NAME ASC

-- Q12. Show all rows for customers whose BRID is 'NYC' or 'HOU'.
SELECT * FROM AMASTER where BRID='NYC' OR BRID='HOU'

-- Q13. Print a constant without using any table.
-- Example output: 5
select 5 as NUMBER

-- Q14. Print a string constant without using any table.
-- Example output column should show SQL as COURSE.
select ' my name is snehith' as COURSE

-- Q15. Show NAME, the constant 'USD' as CURRENCY, and CBAL.
select NAME , 'USD' as CURRENCY , CBAL from AMASTER

-- Q16. Show all AMASTER columns plus a constant 'USD' as CURRENCY.
select *, 'USD' as CURRENCY from AMASTER

-- Q17. Show the number 5 for each row in AMASTER with alias LUCKY_NUMBER.
select *, 5 as LUCKY_NUMBER from AMASTER

-- Q18. Show NAME and CBAL, and also repeat NAME again in the same query.
-- This is just to practice that SQL allows repeated columns.
select NAME, CBAL, NAME from AMASTER

-- Q19. Show all columns twice using *, * from AMASTER.
-- This is only interview practice to understand valid syntax.
select *,* from AMASTER

-- Q20. Show NAME + ' has balance ' + CONVERT(VARCHAR(30), CBAL)
-- using CONVERT instead of CAST.
select NAME + ' has balance ' + CONVERT(VARCHAR(30), CBAL) from AMASTER

-- Q21. Give an alias with spaces.
-- Example: show NAME as [Customer Name]
select NAME as [Customer Name] from AMASTER

-- Q22. Show PID, ACID, and NAME for one product code only,
-- then sort by NAME descending.
select PID, ACID, NAME from AMASTER where BRID='NYC' ORDER BY NAME DESC