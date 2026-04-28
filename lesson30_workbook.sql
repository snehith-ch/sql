USE company;
GO

/*
Lesson 30 Workbook: Correlated Subqueries, EXISTS, and Advanced Subquery Patterns

Run lesson30_setup.sql first.
This workbook uses:
- dbo.AMASTER_L30
- dbo.TMASTER_L30
- dbo.EMPLOYEE_L30

==================================================
1. Current Lesson Topics From Transcript
==================================================
- normal subquery recap
- subquery in WHERE clause
- subquery in SELECT clause
- definition: query in WHERE / SELECT / HAVING can be a subquery
- normal subquery execution: bottom to top
- inner query executes first and passes result to outer query
- second highest balance using nested subqueries
- nth highest balance logic using DISTINCT, TOP, MIN, and nested subqueries
- maximum 32 levels of nesting in subqueries
- correlated subquery concept
- normal subquery vs correlated subquery
- correlated subquery execution: top to bottom
- correlated subquery as loop-in-loop concept
- inner query depends on outer query
- EXISTS function
- NOT EXISTS function
- using EXISTS when we only need to verify matching data, not fetch columns from the second table
- employees with salary higher than their department average

==================================================
2. Previously Covered Topics Needed Here
==================================================
- SELECT, WHERE, ORDER BY
- aggregate functions: MAX, MIN, AVG
- aliases
- = and IN operators
- DISTINCT
- TOP
- joins as comparison background

==================================================
3. Important Points From Transcript
==================================================
- A normal subquery executes first, then its result is substituted into the outer query.
- A subquery can appear in WHERE, SELECT, or HAVING.
- The second-highest question is solved by first eliminating the highest value, then finding the maximum again.
- Nth-highest problems need a different approach from second-highest problems.
- Correlated subqueries work differently from normal subqueries because the inner query depends on the outer query.
- EXISTS checks whether at least one matching row is present.
- NOT EXISTS checks whether no matching row is present.
- When you only need to know whether related rows exist, EXISTS / NOT EXISTS is often more suitable than joining all rows.

==================================================
4. Interview Tricks From Transcript
==================================================
- Interviewers often ask highest, second-highest, or nth-highest questions to check whether you really understand nested subqueries.
- `TOP 1` is not a reliable answer when ties are possible.
- A normal subquery is independent; a correlated subquery is dependent on the outer query.
- If a subquery refers to the outer query alias, that is a big clue that it is a correlated subquery.
- If you try to run a correlated inner query by itself, you may get a multi-part identifier error because it depends on the outer query alias.
- EXISTS does not need actual returned columns from the inner query result set; it only needs to know whether at least one row exists.

==================================================
5. Common Mistakes / Warnings From Transcript
==================================================
- Do not mix aggregate functions and normal selected columns unless the non-aggregated columns are handled correctly with GROUP BY.
- Do not use `=` when the subquery returns multiple values.
- Do not return multiple columns from a SQL Server subquery in this lesson context.
- Do not assume a correlated subquery behaves like a normal subquery.
- Do not join a large transaction table unnecessarily when you only need an existence check.

==================================================
6. Best Practices / Practical Tips From Transcript
==================================================
- Break a complex question into smaller steps before writing the final query.
- For highest/second-highest/nth-highest questions, first decide whether you need one value or the full row details.
- Use clear aliases for inner and outer queries.
- Prefer EXISTS / NOT EXISTS for existence checking when you do not need transaction-table columns in the output.
- Practice subqueries repeatedly; they are major interview topics.

==================================================
7. SQL Rules / Query Rules / Interview Rules
==================================================
- Use `=` when the subquery returns a single value and a single column.
- Use `IN` when the subquery returns multiple values but still only one column.
- In this lesson's SQL Server context, subqueries should return one column, not multiple columns.
- A normal subquery executes from bottom to top.
- A correlated subquery executes from top to bottom.
- In a correlated subquery, the inner query is dependent on the outer query and may run once for each outer-row value.
- If you write an aggregate query with normal columns in `SELECT`, every non-aggregated column must be included in `GROUP BY`.
- Example invalid pattern:
  `SELECT ACID, NAME, CBAL - AVG(CBAL) FROM dbo.AMASTER_L30`
  This is not valid as written.
- `EXISTS` returns true if at least one matching row exists; otherwise false.
- `NOT EXISTS` returns true only when no matching row exists.
- Inside `EXISTS`, `SELECT *` is acceptable in this lesson because the query is checking existence, not returning inner-query columns.
- Maximum 32 levels of nesting are allowed in subqueries.

==================================================
8. Beginner-Friendly Notes
==================================================
Normal Subquery:
- A query inside another query.
- The inner query runs first.
- Its result is passed to the outer query.

Subquery in SELECT:
- Sometimes you need row data plus one overall aggregate value.
- A subquery in SELECT can help you combine them.

Correlated Subquery:
- The inner query uses a value from the outer query.
- So it cannot act independently the same way a normal subquery can.
- The trainer compares it to a loop inside another loop.

EXISTS / NOT EXISTS:
- Use EXISTS when you want rows that have at least one matching related row.
- Use NOT EXISTS when you want rows that have no matching related row.

==================================================
9. Syntax Section
==================================================

Subquery in SELECT clause:
SELECT
    ACID,
    NAME,
    CBAL,
    CBAL - (SELECT AVG(CBAL) FROM dbo.AMASTER_L30) AS BALANCE_DIFF_FROM_AVG
FROM dbo.AMASTER_L30;

Second highest balance:
SELECT *
FROM dbo.AMASTER_L30
WHERE CBAL = (
    SELECT MAX(CBAL)
    FROM dbo.AMASTER_L30
    WHERE CBAL < (
        SELECT MAX(CBAL)
        FROM dbo.AMASTER_L30
    )
);

Third highest balance:
SELECT *
FROM dbo.AMASTER_L30
WHERE CBAL = (
    SELECT MIN(CBAL)
    FROM dbo.AMASTER_L30
    WHERE CBAL IN (
        SELECT DISTINCT TOP (3) CBAL
        FROM dbo.AMASTER_L30
        ORDER BY CBAL DESC
    )
);

Employees with salary higher than department average:
SELECT e1.EMPID, e1.EMPLOYEE_NAME, e1.DEPARTMENT_NAME, e1.SALARY
FROM dbo.EMPLOYEE_L30 AS e1
WHERE e1.SALARY > (
    SELECT AVG(e2.SALARY)
    FROM dbo.EMPLOYEE_L30 AS e2
    WHERE e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME
);

EXISTS:
SELECT *
FROM dbo.AMASTER_L30 AS am
WHERE EXISTS (
    SELECT *
    FROM dbo.TMASTER_L30 AS tm
    WHERE am.ACID = tm.ACID
);

NOT EXISTS:
SELECT *
FROM dbo.AMASTER_L30 AS am
WHERE NOT EXISTS (
    SELECT *
    FROM dbo.TMASTER_L30 AS tm
    WHERE am.ACID = tm.ACID
);

==================================================
10. Level 1: Basic Questions
==================================================
Write your answers below each question.
*/

-- L1-Q1. Show all rows from dbo.AMASTER_L30.
select * from dbo.AMASTER_L30

-- L1-Q2. Show ACID, NAME, and CBAL from dbo.AMASTER_L30.
select ACID, NAME, CBAL from dbo.AMASTER_L30

-- L1-Q3. Show ACID, NAME, CBAL, and the difference between CBAL and average CBAL.
-- Use a subquery in the SELECT clause.
select ACID, NAME, CBAL, CBAL - (select AVG(CBAL) from dbo.AMASTER_L30) as BALANCE_DIFF_FROM_AVG from dbo.AMASTER_L30

-- L1-Q4. Show only the maximum CBAL from dbo.AMASTER_L30.
select MAX(CBAL) as MAX_BALANCE from dbo.AMASTER_L30

-- L1-Q5. Show all customers who have the highest CBAL.
select * from dbo.AMASTER_L30 where CBAL = (select MAX(CBAL) from dbo.AMASTER_L30)

-- L1-Q6. Show all customers who have done at least one transaction.
-- Use EXISTS.
select * from dbo.AMASTER_L30 as am where EXISTS (select * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L1-Q7. Show all customers who have not done any transaction.
-- Use NOT EXISTS.
select * from dbo.AMASTER_L30 as am where NOT EXISTS (select * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L1-Q8. Show employees whose salary is higher than their department average.
select * from dbo.EMPLOYEE_L30 as e1 where e1.SALARY > (select AVG(e2.SALARY) from dbo.EMPLOYEE_L30 as e2 where e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME)

/*
==================================================
11. Level 2: Intermediate Questions
==================================================
*/

-- L2-Q1. Show all customers who have the second-highest CBAL.
select * from dbo.AMASTER_L30 where CBAL = (select MAX(CBAL) from dbo.AMASTER_L30 where CBAL < (select MAX(CBAL) from dbo.AMASTER_L30))

-- L2-Q2. Show only NAME and CBAL for customers who have the second-highest CBAL.
SELECT NAME, CBAL from dbo.AMASTER_L30 where CBAL = (select MAX(CBAL) from dbo.AMASTER_L30 where CBAL < (select MAX(CBAL) FROM dbo.AMASTER_L30))

-- L2-Q3. Show the third-highest distinct CBAL value.
select MIN(CBAL) from dbo.AMASTER_L30 where CBAL IN (select distinct top 3 CBAL from dbo.AMASTER_L30 order by CBAL desc)

-- L2-Q4. Show all customers whose CBAL is equal to the third-highest distinct CBAL.
select * from dbo.AMASTER_L30 where CBAL = (select MIN(CBAL) from dbo.AMASTER_L30 where CBAL IN
(select DISTINCT top 3 CBAL from dbo.AMASTER_L30 order by CBAL desc))

-- L2-Q5. Show ACID, NAME, and CBAL for customers whose CBAL is greater than the average CBAL.
select ACID, NAME, CBAL from dbo.AMASTER_L30 as am where am.CBAL >
(select AVG(pm.CBAL) from dbo.AMASTER_L30 as pm where pm.BRID = am.BRID)

-- L2-Q6. Show employees who are not earning more than their department average.
select * from dbo.EMPLOYEE_L30 as e1 where e1.SALARY <= (select AVG(e2.SALARY) from dbo.EMPLOYEE_L30 as e2 where e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME)

/*
==================================================
12. Level 3: Interview-Style Questions
==================================================
*/

-- L3-Q1. Write a query to show the fourth-highest distinct CBAL value.
select MIN(CBAL) FROM dbo.AMASTER_L30 where CBAL IN (select DISTINCT TOP 4 CBAL from dbo.AMASTER_L30 order by CBAL desc)

-- L3-Q2. Write a query to show all customers whose CBAL is equal to the fourth-highest distinct CBAL.
select * from dbo.AMASTER_L30 where CBAL = (select MIN(CBAL) FROM dbo.AMASTER_L30 where CBAL IN (select DISTINCT TOP 4 CBAL from dbo.AMASTER_L30 order by CBAL desc))

-- L3-Q3. Show customer names where the customer has at least one transaction.
-- Use EXISTS and aliases clearly.
select NAME from dbo.AMASTER_L30 as am where EXISTS (SELECT * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L3-Q4. Show customer names where the customer has no transactions.
-- Use NOT EXISTS and aliases clearly.
select NAME from dbo.AMASTER_L30 as am where NOT EXISTS (SELECT * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L3-Q5. Show employees whose salary is greater than their department average
-- and sort them by department name, then salary descending.
select EMPLOYEE_NAME, SALARY, DEPARTMENT_NAME from dbo.EMPLOYEE_L30 AS e1 where e1.SALARY > (select AVG(e2.SALARY) FROM dbo.EMPLOYEE_L30 as e2 where e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME) order by DEPARTMENT_NAME, SALARY desc

-- L3-Q6. Write a comment explaining why a correlated subquery cannot always be run independently.
--because the inner query references the outer query's alias, so it depends on the outer query for its value and cannot run on its own without that context.

/*
==================================================
13. Level 4: Real-World / Business-Style Questions
==================================================
*/

-- L4-Q1. The bank wants a report of customers whose balance is above the bank-wide average balance.
-- Show ACID, NAME, CBAL, and BALANCE_DIFF_FROM_AVG.
SELECT ACID, NAME, CBAL, CBAL - (select AVG(CBAL) from dbo.AMASTER_L30) AS BALANCE_DIFF_FROM_AVG FROM dbo.AMASTER_L30

-- L4-Q2. The bank wants to identify customers sharing the second-highest balance.
SELECT NAME, CBAL FROM dbo.AMASTER_L30 where CBAL = (SELECT MIN(CBAL) from dbo.AMASTER_L30 where CBAL IN (SELECT DISTINCT TOP 2 CBAL from dbo.AMASTER_L30 order by CBAL desc))

-- L4-Q3. The bank wants the names of customers who have performed at least one transaction,
-- but it does not need transaction details.
SELECT NAME FROM dbo.AMASTER_L30 as am where EXISTS (SELECT * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L4-Q4. The bank wants the names of customers who have never performed any transaction.
SELECT NAME FROM dbo.AMASTER_L30 as am where NOT EXISTS (SELECT * from dbo.TMASTER_L30 as tm where am.ACID = tm.ACID)

-- L4-Q5. HR wants employees who are paid above the average of their own department.
SELECT EMPLOYEE_NAME, DEPARTMENT_NAME, SALARY FROM dbo.EMPLOYEE_L30 as e1 where e1.SALARY > (SELECT AVG(e2.SALARY) from dbo.EMPLOYEE_L30 as e2 where e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME)

/*
==================================================
14. Level 5: Rapid Revision Questions
==================================================
*/

-- L5-Q1. Write one query using a subquery in the SELECT clause.
SELECT ACID, NAME, CBAL, CBAL - (SELECT AVG(CBAL) FROM dbo.AMASTER_L30) AS BALANCE_DIFF_FROM_AVG FROM dbo.AMASTER_L30

-- L5-Q2. Write one query for the second-highest balance.
SELECT * FROM dbo.AMASTER_L30 WHERE CBAL = (SELECT MAX(CBAL) FROM dbo.AMASTER_L30 WHERE CBAL < (SELECT MAX(CBAL) FROM dbo.AMASTER_L30))

-- L5-Q3. Write one query using EXISTS.
SELECT NAME FROM dbo.AMASTER_L30 AS am WHERE EXISTS (SELECT * FROM dbo.TMASTER_L30 AS tm WHERE am.ACID = tm.ACID)

-- L5-Q4. Write one query using NOT EXISTS.
SELECT NAME FROM dbo.AMASTER_L30 AS am WHERE NOT EXISTS (SELECT * FROM dbo.TMASTER_L30 AS tm WHERE am.ACID = tm.ACID)

-- L5-Q5. Write one query using a correlated subquery on dbo.EMPLOYEE_L30.
SELECT EMPLOYEE_NAME, DEPARTMENT_NAME, SALARY FROM dbo.EMPLOYEE_L30 AS e1 WHERE e1.SALARY > (SELECT AVG(e2.SALARY) FROM dbo.EMPLOYEE_L30 AS e2 WHERE e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME)

-- L5-Q6. Write one comment stating the difference in execution order
-- between a normal subquery and a correlated subquery.
-- A normal subquery executes from the bottom up, meaning the inner query runs first and its result is passed to the outer query. A correlated subquery executes from the top down, meaning the outer query runs first and for each row of the outer query, the inner query executes and can reference the current row of the outer query.

/*
==================================================
15. Mixed Interview Practice
==================================================
*/

-- MIX-Q1. Show ACID, NAME, CBAL, BALANCE_DIFF_FROM_AVG,
-- and include only customers who have done at least one transaction.
SELECT ACID, NAME, CBAL, CBAL - (SELECT AVG(CBAL) FROM dbo.AMASTER_L30) AS BALANCE_DIFF_FROM_AVG FROM dbo.AMASTER_L30 AS am WHERE EXISTS (SELECT * FROM dbo.TMASTER_L30 AS tm WHERE am.ACID = tm.ACID)

-- MIX-Q2. Show all customers whose CBAL is equal to the second-highest distinct CBAL
-- and who have at least one transaction.
SELECT * FROM dbo.AMASTER_L30 AS am WHERE CBAL = (SELECT MIN(CBAL) FROM dbo.AMASTER_L30 WHERE CBAL IN (SELECT DISTINCT TOP 2 CBAL FROM dbo.AMASTER_L30 ORDER BY CBAL DESC)) AND EXISTS (SELECT * FROM dbo.TMASTER_L30 AS tm WHERE am.ACID = tm.ACID)

-- MIX-Q3. Show employees whose salary is above their department average,
-- and also show the difference between their salary and their department average.
SELECT EMPLOYEE_NAME, DEPARTMENT_NAME, SALARY, SALARY - (SELECT AVG(SALARY) FROM dbo.EMPLOYEE_L30 AS e2 WHERE e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME) AS SALARY_DIFF_FROM_DEPT_AVG FROM dbo.EMPLOYEE_L30 AS e1 WHERE e1.SALARY > (SELECT AVG(SALARY) FROM dbo.EMPLOYEE_L30 AS e2 WHERE e2.DEPARTMENT_NAME = e1.DEPARTMENT_NAME)

/*
==================================================
16. Optional Challenge Questions
==================================================
*/

-- CH-Q1. Write the fifth-highest distinct CBAL value query.
SELECT NAME, CBAL FROM dbo.AMASTER_L30 where CBAL = (SELECT MIN(CBAL) from dbo.AMASTER_L30 where CBAL IN (SELECT DISTINCT TOP 5 CBAL from dbo.AMASTER_L30 order by CBAL desc))

-- CH-Q2. Show all customers whose CBAL is equal to the fifth-highest distinct CBAL.
SELECT * FROM dbo.AMASTER_L30 where CBAL = (SELECT MIN(CBAL) from dbo.AMASTER_L30 where CBAL IN (SELECT DISTINCT TOP 5 CBAL from dbo.AMASTER_L30 order by CBAL desc))

-- CH-Q3. Show all customers from dbo.AMASTER_L30 who do not appear in dbo.TMASTER_L30,
-- using NOT EXISTS.
SELECT NAME FROM dbo.AMASTER_L30 AS am WHERE NOT EXISTS (SELECT * FROM dbo.TMASTER_L30 AS tm WHERE am.ACID = tm.ACID)

-- CH-Q4. Write a comment explaining why EXISTS can be faster or more suitable
-- than a join when you only need to know whether a matching row exists.
-- EXISTS can be faster or more suitable than a join when you only need to know whether a matching row exists because it stops as soon as it finds a match, whereas a join might need to process all matching rows. This can lead to better performance, especially when the related table has many rows or when there are multiple matches for each row in the outer query. Additionally, EXISTS does not return columns from the inner query, so it can be more efficient when you do not need that data.


/*
==================================================
17. Transcript Coverage Checklist
==================================================
Current transcript topics covered:
- normal subquery recap
- subquery in WHERE clause
- subquery in SELECT clause
- query in WHERE / SELECT / HAVING as subquery definition
- normal subquery execution order
- second-highest balance with nested subqueries
- nth-highest balance idea
- maximum 32 levels of nesting
- correlated subquery concept
- normal vs correlated subquery
- correlated execution order
- dependent vs independent subquery idea
- loop-in-loop comparison
- EXISTS
- NOT EXISTS
- employees with salary higher than department average

Previous topics reused for revision/practice:
- SELECT, WHERE, ORDER BY
- MAX, MIN, AVG
- aliases
- DISTINCT
- TOP
- IN and =

Topics mentioned in transcript but not fully taught in this lesson:
- detailed HAVING-clause example was referenced but not demonstrated here
- future more examples of EXISTS were mentioned

Important transcript points not turned into direct questions:
- multi-part identifier errors can hint that a query is correlated because it references the outer query alias
- practice is essential for subqueries and interviews

Setup files created for this lesson:
- lesson30_setup.sql

Run order for this lesson:
1. Run lesson30_setup.sql
2. Solve lesson30_workbook.sql
*/
