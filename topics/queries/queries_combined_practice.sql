USE company;
GO

/*
Queries Combined Practice

Run queries_combined_setup.sql first.

These questions practice the same concepts as the lessons, but the exact
questions are intentionally different from the notebook examples.
Write your answer below each question.
*/

/*
============================================================
LEVEL 1: BASIC SELECT, WHERE, ORDER BY
============================================================
*/

-- Q1. Show ACID, NAME, BRID, and STATUS for all accounts.
select ACID, NAME, BRID, STATUS from <table name>

-- Q2. Show all columns for accounts opened in branch BR2.
select * from <table name> where BRID = BR2

-- Q3. Show ACID, NAME, PID, and CBAL for active accounts only.
select ACID, NAME, PID, CBAL from <table name> where STATUS = A

-- Q4. Show accounts where CBAL is greater than 30000, sorted by CBAL descending.


-- Q5. Show only SB and CA accounts using IN.


-- Q6. Show account names starting with the letter S.


-- Q7. Show ACID, NAME, and a constant column called Currency with value INR.


-- Q8. Show NAME and a sentence: <NAME> belongs to branch <BRID>.


-- Q9. Show NAME and CBAL as one string: Balance is INR <amount>.


-- Q10. Show DOO in style 103 and style 107 using CONVERT.


/*
============================================================
LEVEL 2: FUNCTIONS, NULLS, CASE, AGGREGATES
============================================================
*/

-- Q11. Show each transaction with CHQ_NO. If CHQ_NO is NULL, display 0.


-- Q12. Use NULLIF to compare CBAL and UBAL for every account.


-- Q13. Show NAME in uppercase, lowercase, first 4 characters, and name length.


-- Q14. Replace spaces in NAME with hyphens.


-- Q15. Categorize accounts as:
-- Low Balance when CBAL < 10000
-- Medium Balance when CBAL between 10000 and 50000
-- High Balance otherwise.


-- Q16. Count total accounts, active accounts, and inactive/closed accounts.


-- Q17. Find SUM, AVG, MIN, and MAX of CBAL for only active accounts.


-- Q18. Count distinct branches available in Q_ACCOUNT_MASTER.


-- Q19. Show product-wise account count and total balance.


-- Q20. Show branch-wise average balance, only for branches whose average balance is above 30000.


/*
============================================================
LEVEL 3: JOINS, GROUP BY, HAVING, DATE FUNCTIONS
============================================================
*/

-- Q21. Join accounts with branch master and show ACID, NAME, BRANCH_NAME, CITY.


-- Q22. Join accounts with product master and show NAME, PRODUCT_NAME, MIN_BAL, CBAL.


-- Q23. Show accounts whose CBAL is below their product MIN_BAL.


-- Q24. Show branch name wise account count.


-- Q25. Show branch and product wise account count.


-- Q26. Show transaction type wise total amount for year 2021.


-- Q27. Show month name wise transaction count for 2021, sorted by month number.


-- Q28. Show accounts opened between 2020 and 2023 using DATEPART.


-- Q29. Show transactions between '2021-01-01' and '2021-12-31' using a safe date range.


-- Q30. Show branches having more than 2 accounts using GROUP BY and HAVING.


/*
============================================================
LEVEL 4: SUBQUERIES, EXISTS, SYSTEM TABLES
============================================================
*/

-- Q31. Find the account or accounts with the highest CBAL.


-- Q32. Find the account or accounts with the second highest distinct CBAL using subqueries.


-- Q33. Find accounts whose CBAL is greater than the overall average CBAL.


-- Q34. Show each account with DifferenceFromAverage = CBAL - overall average CBAL.


-- Q35. Find accounts that have at least one transaction using EXISTS.


-- Q36. Find accounts that have no transaction using NOT EXISTS.


-- Q37. Find employees whose salary is greater than their own department average using a correlated subquery.


-- Q38. Find courses that have at least one enrollment using EXISTS.


-- Q39. Count how many user tables in this database start with Q_.


-- Q40. Find number of columns in Q_TXN_MASTER using sys.columns.


-- Q41. Write an IF EXISTS block that prints 'Q_ACCOUNT_MASTER exists' if the table exists.


/*
============================================================
LEVEL 5: DERIVED TABLES, CUBE, ROLLUP
============================================================
*/

-- Q42. Create a derived table that returns ACID and transaction count from Q_TXN_MASTER.
-- Join it to Q_ACCOUNT_MASTER to show account name and transaction count.


-- Q43. Rewrite Q42 so the derived table first filters transactions for year 2021 only.


-- Q44. Find month-wise number of new customers from Q_CUSTOMER_SALES.
-- New customer means the customer's first purchase month.


-- Q45. Find department-wise average salary using a derived table, then join it back
-- to employee table to show employees above department average.


-- Q46. Show item/color wise total quantity from Q_ITEM_SALES.


-- Q47. Use GROUP BY CUBE on ITEM_NAME and COLOR.


-- Q48. Use GROUP BY ROLLUP on ITEM_NAME and COLOR.


-- Q49. In comments, explain one difference between CUBE and ROLLUP.


/*
============================================================
LEVEL 6: RANKING FUNCTIONS
============================================================
*/

-- Q50. Add ROW_NUMBER over ACID for all accounts.


-- Q51. Get only rows 3 to 7 using ROW_NUMBER and a derived table.


-- Q52. Get every third row from accounts using ROW_NUMBER and modulo logic.


-- Q53. Show RANK and DENSE_RANK based on CBAL descending.


-- Q54. Find all accounts with the 2nd highest distinct balance using DENSE_RANK.


-- Q55. Find the highest balance account in each branch using DENSE_RANK and PARTITION BY.


-- Q56. Find the second highest balance account in each branch.


-- Q57. Split accounts into 4 groups using NTILE.


-- Q58. Split accounts into 2 groups within each branch using NTILE and PARTITION BY.


/*
============================================================
LEVEL 7: CTE PRACTICE
============================================================
*/

-- Q59. Use a CTE to get row numbers and return row number 5 only.


-- Q60. Use a CTE to find branches with the highest number of accounts.


-- Q61. Use two CTEs:
-- First CTE: branch-wise account count.
-- Second CTE: dense rank by account count descending.
-- Return rank 1 branches.


-- Q62. Use a CTE to find product-wise total balance, then return products above average product total.


-- Q63. Use a CTE to find first purchase date per customer, then return month-wise new customer count.


/*
============================================================
MIXED INTERVIEW PRACTICE
============================================================
*/

-- Q64. Show branch name, product name, account count, and total balance.
-- Only include active accounts.
-- Only show groups where total balance is above 40000.


-- Q65. Find customers whose balance is greater than the average balance of their branch.


-- Q66. Find branches where at least one account has a cheque amount in unclear balance
-- meaning UBAL > CBAL.


-- Q67. Show transaction type wise count and amount, but include only transaction types
-- whose total amount is greater than the average transaction amount of all transactions.


-- Q68. Generate SELECT statements for all tables starting with Q_ using sys.tables.


-- Q69. Find students from USA who enrolled in any course.


-- Q70. Find courses with no enrollment using LEFT JOIN.


-- Q71. Find courses with no enrollment using NOT EXISTS.


-- Q72. Create a report with account name, branch city, product name, customer type by CBAL,
-- and formatted opening date.


/*
============================================================
RAPID REVISION QUESTIONS
Answer in comments.
============================================================
*/

-- R1. What does SELECT * mean?

-- R2. Which clause filters rows?

-- R3. Which clause sorts rows?

-- R4. What is the default sort order?

-- R5. Why do string values need single quotes?

-- R6. What is an alias?

-- R7. How do you write an alias with spaces?

-- R8. Why is CAST needed during string + money concatenation?

-- R9. When is CONVERT preferred over CAST?

-- R10. What does BETWEEN include?

-- R11. What is the difference between WHERE and HAVING?

-- R12. Where should GROUP BY come?

-- R13. Where should HAVING come?

-- R14. What happens if a selected non-aggregate column is missing from GROUP BY?

-- R15. When should you use a join?

-- R16. When should you use a subquery?

-- R17. What does EXISTS check?

-- R18. Where do you place IF EXISTS when dropping a table safely?

-- R19. What is a derived table?

-- R20. Does a derived table need an alias?

-- R21. Why can we not use ROW_NUMBER alias directly in WHERE?

-- R22. Difference between RANK and DENSE_RANK?

-- R23. What does PARTITION BY do?

-- R24. What does NTILE do?

-- R25. What is a CTE?

-- R26. Why might a semicolon be needed before WITH?

-- R27. Difference between CUBE and ROLLUP?

-- R28. What is the performance rule: filter early or join early?

-- R29. Which system table stores table metadata?

-- R30. Which system table stores column metadata?

/*
============================================================
COVERAGE CHECKLIST
============================================================
[ ] SELECT all columns/all rows
[ ] SELECT specific columns
[ ] WHERE row filtering
[ ] AND / OR / IN / BETWEEN / LIKE
[ ] ORDER BY ASC/DESC
[ ] constants and aliases
[ ] concatenation
[ ] CAST and CONVERT
[ ] date style conversion
[ ] NULL functions: ISNULL, COALESCE, NULLIF
[ ] aggregate functions
[ ] GROUP BY
[ ] HAVING
[ ] date functions
[ ] string functions
[ ] CASE
[ ] joins
[ ] subqueries
[ ] correlated subqueries
[ ] EXISTS / NOT EXISTS
[ ] system tables
[ ] IF EXISTS / IF NOT EXISTS
[ ] derived tables
[ ] CUBE / ROLLUP
[ ] ranking functions
[ ] PARTITION BY
[ ] CTE
*/
