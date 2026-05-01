USE company;
GO

/*
Lesson 17 Test: Basic SQL Retrieval
Table used: AMASTER

Write your queries below each question.
No hints.
*/

-- 1. Show all columns and all rows from AMASTER.
select * from AMASTER

-- 2. Show ACID, NAME, and CBAL for all rows.
select ACID, NAME, CBAL from AMASTER

-- 3. Show all rows where BRID is 'NYC'.
select * from AMASTER where BRID='NYC'

-- 4. Show ACID, NAME, PID, and CBAL for customers whose BRID is 'LA' or 'HOU'.
select ACID, NAME, PID, CBAL from AMASTER where BRID='LA' OR BRID='HOU'
-- 5. Show all rows where BRID is 'NYC' and CBAL is greater than 5000.
select * from AMASTER where BRID='NYC' and CBAL>5000

-- 6. Show ACID, NAME, and CBAL sorted by NAME in ascending order.
select ACID, NAME, CBAL from AMASTER order by name ASC

-- 7. Show NAME and a constant value 'USD' with the alias CURRENCY.
select NAME, 'USD' as CURRENCY from AMASTER

-- 8. Show NAME as [Customer Name] and CBAL as [Clear Balance].
select NAME as [Customer Name], CBAL as [Clear Balance] from AMASTER

-- 9. Show a single column that prints:
-- <NAME> is learning SQL
-- for every row.
select NAME + ' is learning SQL' from AMASTER

-- 10. Show a single column that prints:
-- <NAME> has balance <CBAL>
-- for every row using CONVERT.
select NAME + ' has balance ' + CONVERT(VARCHAR(30), CBAL) as BALANCE from AMASTER
