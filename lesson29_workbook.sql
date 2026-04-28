USE company;
GO

/*
Lesson 29 Workbook: NULLIF, BETWEEN, CASE, and Intro to Subqueries

Run lesson29_setup.sql first.
This workbook uses dbo.AMASTER_L29.

==================================================
1. Current Lesson Topics From Transcript
==================================================
- NULLIF function
- difference between ISNULL and NULLIF
- BETWEEN operator
- BETWEEN with DATEPART on year values
- CASE statement as SQL alternative to if/else
- alias using AS and alias = expression style
- normal subquery in WHERE clause
- why TOP 1 with ORDER BY is not always correct for "who has the highest balance"
- subquery execution order
- when to use = and when to use IN with subqueries
- SQL Server rule: subquery should return a single column

==================================================
2. Previously Covered Topics Needed Here
==================================================
- SELECT, WHERE, ORDER BY
- TOP
- aggregate functions: MAX
- DATEPART
- concatenation with +
- aliases
- ISNULL / COALESCE as revision references

==================================================
3. Important Points From Transcript
==================================================
- NULLIF returns NULL when both expressions are equal.
- If the two expressions are not equal, NULLIF returns the first expression.
- BETWEEN includes lower limit, upper limit, and the values in between.
- In SQL, CASE is commonly used where programming languages use if/else.
- Subqueries are also called nested queries or inner queries.
- Use `=` operator when the subquery returns a single value and a single column.
- Use `IN` operator when the subquery returns multiple values but still only one column.
- In this lesson's SQL Server context, subqueries should return only one column, not multiple columns.
- In the highest-balance question, the query is really two queries:
  1. what is the maximum balance
  2. who has that balance

==================================================
4. Interview Tricks From Transcript
==================================================
- `TOP 1 ... ORDER BY CBAL DESC` looks correct for highest balance, but it fails when multiple customers share the same maximum balance.
- `WHERE CBAL = MAX(CBAL)` is invalid because aggregate functions cannot be used like that in WHERE.
- `SELECT NAME, MAX(CBAL) ...` does not answer "who has the highest balance" correctly in this case.
- SQL Server interviewers often ask highest salary / highest balance questions to test whether you know subqueries.
- For a single-value subquery, use `=`.
- For a multiple-value single-column subquery, use `IN`.

==================================================
5. Common Mistakes / Warnings From Transcript
==================================================
- Do not write `BETWEEN 10000 TO 50000`; use `BETWEEN 10000 AND 50000`.
- Do not assume listening alone is learning; practice is required.
- Do not use multiple columns inside a SQL Server subquery when a single-column subquery is required.
- Do not assume `TOP 1` solves tie cases.
- Do not mix old revision topics with new lesson topics in your notes without labeling them.

==================================================
6. Best Practices / Practical Tips From Transcript
==================================================
- Practice case studies regularly; only watching videos is not enough.
- Use meaningful aliases for output columns.
- Think of business questions in smaller parts before writing SQL.
- Break advanced queries into inner and outer logic first.
- For dynamic "highest" or "lowest" questions, prefer subqueries over hardcoded `TOP 1` assumptions.

==================================================
7. SQL Rules / Query Rules / Interview Rules
==================================================
- Use `=` when the subquery returns a single value and a single column.
- Use `IN` when the subquery returns multiple values but still only one column.
- In this lesson's SQL Server context, do not return multiple columns from the subquery.
- Do not write `WHERE CBAL = MAX(CBAL)`; aggregate functions cannot be used that way in `WHERE`.
- If you write an aggregate query with a normal column, every non-aggregated column in `SELECT` must be included in `GROUP BY`.
- Example invalid pattern:
  `SELECT NAME, MAX(CBAL) FROM dbo.AMASTER_L29`
  This is not valid unless `NAME` is grouped appropriately.
- `TOP 1 ... ORDER BY ... DESC` is not a safe answer for highest-balance questions when ties are possible.
- `BETWEEN` includes both the lower value and the upper value.

==================================================
8. Beginner-Friendly Notes
==================================================
NULLIF:
- Syntax: NULLIF(value1, value2)
- If value1 = value2, result is NULL.
- If value1 <> value2, result is value1.

BETWEEN:
- Syntax: column BETWEEN low_value AND high_value
- It includes both boundaries.
- Equivalent idea: column >= low_value AND column <= high_value

CASE:
- SQL does not use regular programming-style if/else inside normal queries the same way.
- Instead, we use CASE.
- CASE creates conditional output in a query.

Subquery:
- A query inside another query.
- In this lesson, the main form is a subquery inside the WHERE clause.
- SQL Server runs the inner query first, then uses its result in the outer query.
- If the inner query returns one value, outer query commonly uses `=`.
- If the inner query returns multiple values in one column, outer query commonly uses `IN`.
- In this lesson, do not write a subquery that returns multiple columns.

==================================================
9. Syntax Section
==================================================

NULLIF examples:
SELECT NULLIF(4, 4) AS RESULT;
SELECT NULLIF(10, 8) AS RESULT;

BETWEEN example:
SELECT NAME, CBAL
FROM dbo.AMASTER_L29
WHERE CBAL BETWEEN 10000 AND 50000;

BETWEEN with year example:
SELECT NAME, DOO
FROM dbo.AMASTER_L29
WHERE DATEPART(YEAR, DOO) BETWEEN 2011 AND 2020;

CASE example:
SELECT NAME,
       CBAL,
       CASE
           WHEN CBAL < 10000 THEN 'Silver'
           WHEN CBAL BETWEEN 10000 AND 50000 THEN 'Gold'
           ELSE 'Diamond'
       END AS CUSTOMER_TYPE
FROM dbo.AMASTER_L29;

Subquery example:
SELECT NAME, CBAL
FROM dbo.AMASTER_L29
WHERE CBAL = (
    SELECT MAX(CBAL)
    FROM dbo.AMASTER_L29
);

Subquery with IN example:
SELECT NAME, BRID, CBAL
FROM dbo.AMASTER_L29
WHERE BRID IN (
    SELECT BRID
    FROM dbo.AMASTER_L29
    WHERE CBAL = 50000
);

Alias with equals style example:
SELECT CUSTOMER_COUNT = COUNT(*)
FROM dbo.AMASTER_L29;

==================================================
10. Level 1: Basic Questions
==================================================
Write your answers below each question.
*/

-- L1-Q1. Show all rows from dbo.AMASTER_L29.
select * from dbo.AMASTER_L29

-- L1-Q2. Show ACID, NAME, CBAL, and UBAL.
select ACID, NAME, CBAL, UBAL from dbo.AMASTER_L29

-- L1-Q3. Use NULLIF with constants 4 and 4.
select NULLIF(4, 4) as RESULT

-- L1-Q4. Use NULLIF with constants 10 and 8.
select NULLIF(10, 8) as RESULT

-- L1-Q5. Show NAME, CBAL, UBAL, and NULLIF(CBAL, UBAL) as BALANCE_CHECK.
select NAME, CBAL, UBAL, NULLIF(CBAL, UBAL) as  BALANCE_CHECK from dbo.AMASTER_L29

-- L1-Q6. Show NAME and CBAL for customers whose CBAL is between 10000 and 50000.
select NAME, CBAL from dbo.AMASTER_L29 where CBAL BETWEEN 10000 AND 50000

-- L1-Q7. Show NAME and DOO for customers whose account opening year is between 2011 and 2020.
select NAME, DOO from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2011 AND 2020

-- L1-Q8. Show NAME and a CASE-based column that returns:
-- Silver if CBAL < 10000
-- Gold if CBAL BETWEEN 10000 AND 50000
-- Diamond otherwise
select NAME, 
              CASE
                   WHEN CBAL<10000 THEN 'silver'
                   WHEN CBAL BETWEEN 10000 AND 50000 THEN 'gold'
                   ELSE 'diamond'
              END AS CUSTOMER_TYPE
from dbo.AMASTER_L29

/*
==================================================
11. Level 2: Intermediate Questions
==================================================
*/

-- L2-Q1. Show NAME, CBAL, and a CASE-based CUSTOMER_TYPE column using:
-- Silver for CBAL < 10000
-- Gold for CBAL BETWEEN 10000 AND 30000
-- Platinum for CBAL BETWEEN 30001 AND 49999
-- Diamond otherwise
select NAME, CBAL,
              CASE
                 WHEN CBAL<10000 THEN 'silver'
                 WHEN CBAL BETWEEN 10000 AND 30000 THEN 'Gold'
                 WHEN CBAL BETWEEN 30001 AND 49999 THEN 'Platinum'
                 ELSE 'Diamond'
             END as CUSTOMER_TYPE
from dbo.AMASTER_L29

-- L2-Q2. Show only the customers whose CBAL and UBAL are different.
-- Also display NULLIF(CBAL, UBAL) as FIRST_BALANCE_IF_DIFFERENT.
select NAME, CBAL, UBAL, NULLIF(CBAL, UBAL) as FIRST_BALANCE_IF_DIFFERENT from dbo.AMASTER_L29 where CBAL != UBAL

-- L2-Q3. Show NAME, DOO, and opening year for customers whose opening year is between 2013 and 2019.
-- select NAME, DOO from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2013 AND 2019 as OPENING_YEAR :- this query is wrong because we cannot use alias in where clause
select NAME, DOO, DATEPART(YEAR, DOO) as OPENING_YEAR from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2013 AND 2019

-- L2-Q4. Show a column alias using equals syntax:
-- CUSTOMER_COUNT = total number of customers
select CUSTOMER_COUNT = COUNT(*) from dbo.AMASTER_L29

-- L2-Q5. Show NAME and CBAL for customers whose CBAL is between 7500 and 22000.
select NAME, CBAL from dbo.AMASTER_L29 where CBAL BETWEEN 7500 AND 22000

-- L2-Q6. Show NAME, CBAL, and a CASE result where:
-- if BRID is 'NYC' then 'Metro Branch'
-- else 'Non-Metro Branch'
select NAME, CBAL, CASE WHEN BRID='NYC' THEN 'Metro Branch' ELSE 'Non-Metro Branch' END as BRANCH_TYPE from dbo.AMASTER_L29

/*
==================================================
12. Level 3: Interview-Style Questions
==================================================
*/

-- L3-Q1. Write the correct query to show all customers who have the highest CBAL.
-- Do not use TOP 1.
select * from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)

-- L3-Q2. Write the query to show only the names of customers who have the highest CBAL.
select NAME from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)

-- L3-Q3. Write a query that returns all customers whose CBAL is equal to the minimum CBAL.
select * from dbo.AMASTER_L29 where CBAL=(select MIN(CBAL) from dbo.AMASTER_L29)

-- L3-Q4. Use a subquery that returns multiple branch codes,
-- then use IN in the outer query to list all customers from those branches.
-- Condition for inner query:
-- branches where at least one customer has CBAL = 50000
select NAME, BRID, CBAL from dbo.AMASTER_L29 where BRID IN (select BRID from dbo.AMASTER_L29 where CBAL=50000)

-- L3-Q5. Show NAME, CBAL, and a CASE-based label:
-- 'Matched' if CBAL = UBAL
-- 'Mismatch' otherwise
select NAME, CBAL, CASE WHEN CBAL=UBAL THEN 'Matched' ELSE 'Mismatch' END as BALANCE_STATUS from dbo.AMASTER_L29

-- L3-Q6. Write a comment explaining why
-- SELECT TOP 1 NAME, CBAL FROM dbo.AMASTER_L29 ORDER BY CBAL DESC
-- is not fully correct for "who has the highest balance".
-- This query only returns one customer, even if multiple customers share the same highest balance. It does not account for ties.

/*
==================================================
13. Level 4: Real-World / Business-Style Questions
==================================================
*/

-- L4-Q1. The bank wants a report of customers whose money is fully cleared.
-- Show NAME, CBAL, UBAL, and a BALANCE_STATUS column using CASE.
select NAME, CBAL, UBAL, CASE WHEN CBAL=UBAL THEN 'Cleared' ELSE 'Not Cleared' END as BALANCE_STATUS from dbo.AMASTER_L29 where CBAL=UBAL

-- L4-Q2. The bank wants to review customers who opened accounts between 2014 and 2020.
-- Show ACID, NAME, DOO, and opening year.
select NAME, ACID, DOO, DATEPART(YEAR, DOO) as OPENING_YEAR from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2014 AND 2020 

-- L4-Q3. The bank wants to identify premium customers.
-- Show NAME, CBAL, and CUSTOMER_SEGMENT where:
-- Silver < 10000
-- Gold 10000 to 30000
-- Platinum 30001 to 49999
-- Diamond 50000 and above
select NAME, CBAL, CASE WHEN CBAL<10000 THEN 'Silver' WHEN CBAL BETWEEN 10000 AND 30000 THEN 'Gold' WHEN CBAL BETWEEN 30001 AND 49999 THEN 'Platinum' ELSE 'Diamond' END as CUSTOMER_SEGMENT from dbo.AMASTER_L29

-- L4-Q4. The bank wants the names of every customer sharing the top balance.
select NAME from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)

-- L4-Q5. The bank wants to flag branch type.
-- Show NAME, BRID, and CASE-based BRANCH_TYPE:
-- 'City' for NYC, LA, HOU
-- 'Other' for all other branches
select NAME, BRID, CASE WHEN BRID IN ('NYC', 'LA', 'HOU') THEN 'City' ELSE 'Other' END as BRANCH_TYPE from dbo.AMASTER_L29

/*
==================================================
14. Level 5: Rapid Revision Questions
==================================================
*/

-- L5-Q1. Write one query using NULLIF with two constants that returns NULL.
select NULLIF(5, 5) as RESULT

-- L5-Q2. Write one query using BETWEEN on CBAL.
select NAME, CBAL from dbo.AMASTER_L29 where CBAL BETWEEN 20000 AND 40000

-- L5-Q3. Write one query using DATEPART with BETWEEN on DOO.
select NAME, DOO from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2014 AND 2020

-- L5-Q4. Write one query using CASE.
select NAME, CBAL, CASE WHEN CBAL<10000 THEN 'Silver' WHEN CBAL BETWEEN 10000 AND 30000 THEN 'Gold' WHEN CBAL BETWEEN 30001 AND 49999 THEN 'Platinum' ELSE 'Diamond' END as CUSTOMER_TYPE from dbo.AMASTER_L29

-- L5-Q5. Write one query using a subquery with MAX(CBAL).
select NAME, CBAL from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)

-- L5-Q6. Write one query using alias = expression style.
select CUSTOMER_COUNT = COUNT(*) from dbo.AMASTER_L29

/*
==================================================
15. Mixed Interview Practice
==================================================
*/

-- MIX-Q1. Show NAME, DOO, CBAL, and CUSTOMER_TYPE where:
-- only include customers opened between 2011 and 2020
-- use CASE on CBAL
-- sort by CBAL descending
select NAME, DOO, CBAL, DATEPART(YEAR, DOO) as OPENING_YEAR, CASE WHEN CBAL<10000 THEN 'Silver' WHEN CBAL BETWEEN 10000 AND 30000 THEN 'Gold' WHEN CBAL BETWEEN 30001 AND 49999 THEN 'Platinum' ELSE 'Diamond' END as CUSTOMER_TYPE from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2011 AND 2020 order by CBAL desc

-- MIX-Q2. Show all customers from branches that contain at least one customer
-- whose CBAL is the maximum balance in the table.
select NAME, BRID, CBAL from dbo.AMASTER_L29 where BRID IN (select BRID from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)) ORDER BY CBAL DESC

-- MIX-Q3. Show NAME, CBAL, UBAL, NULLIF(CBAL, UBAL) as BALANCE_COMPARE,
-- and a CASE-based STATUS_TEXT that says:
-- 'Same' if CBAL = UBAL
-- 'Different' otherwise
select NAME, CBAL, UBAL, NULLIF(CBAL, UBAL) as BALANCE_COMPARE, CASE WHEN CBAL=UBAL THEN 'Same' ELSE 'Different' END as STATUS_TEXT from dbo.AMASTER_L29

/*
==================================================
16. Optional Challenge Questions
==================================================
*/

-- CH-Q1. Write the highest-balance customer query in a way that still returns
-- every tied customer correctly.
select NAME, CBAL from dbo.AMASTER_L29 where CBAL=(select MAX(CBAL) from dbo.AMASTER_L29)

-- CH-Q2. Show NAME and a CASE-based title where:
-- if STATUS = 'A' then prefix the name with 'Active - '
-- else prefix the name with 'Inactive - '
select NAME, CASE WHEN STATUS = 'A' THEN 'Active - ' + NAME ELSE 'Inactive - ' + NAME END as STATUS_TITLE from dbo.AMASTER_L29

-- CH-Q3. Show customers whose opening year is between 2012 and 2017
-- and whose CBAL is between 10000 and 50000.
select NAME, DATEPART(YEAR, DOO) as OPENING_YEAR, CBAL from dbo.AMASTER_L29 where DATEPART(YEAR, DOO) BETWEEN 2012 AND 2017 and CBAL BETWEEN 10000 AND 50000

-- CH-Q4. Use a subquery with IN to list all customers from branches
-- where at least one customer has UBAL > CBAL.
select NAME, BRID from dbo.AMASTER_L29 where BRID IN (select BRID from dbo.AMASTER_L29 where UBAL > CBAL)

/*
==================================================
17. Transcript Coverage Checklist
==================================================
Current transcript topics covered:
- NULLIF
- difference between ISNULL and NULLIF
- BETWEEN operator
- BETWEEN with DATEPART(year, DOO)
- CASE statement
- alias with AS and alias = expression
- normal subquery in WHERE
- subquery execution order
- = vs IN for subqueries
- single-column subquery rule in SQL Server
- interview trap: TOP 1 is not enough for tied maximum values

Previous topics reused for revision/practice:
- SELECT, WHERE, ORDER BY
- TOP
- MAX aggregate
- DATEPART
- concatenation
- aliases

Topics mentioned in transcript but not actually taught in this lesson:
- full string functions lesson
- correlated subqueries
- derived tables
- ranking functions
- CTEs

Important transcript points not turned into direct questions:
- practice case studies regularly
- only listening is not learning
- queries are the major part of real SQL work

Run order for this lesson:
1. Run lesson29_setup.sql
2. Solve lesson29_workbook.sql
*/
