USE company;
GO

/*
T-SQL Programming Practice

Run order:
1. Run tsql_programming_setup.sql.
2. Read tsql_programming_revision_notebook.md.
3. Solve this file.

These questions practice the same concepts as the lessons, but the exact
questions are different so you get real practice.

For CREATE PROCEDURE / CREATE OR ALTER PROCEDURE answers, keep GO before
and after the procedure body, then run EXEC in the next batch.
*/

/*
==================================================
Level 1 - Local Variables
==================================================
*/

-- Q1. Declare three INT variables: @FirstNumber, @SecondNumber, @Answer.
-- Store 125 and 75 in the first two variables.
-- Store their sum in @Answer.
-- Print @Answer.
-- TODO:


-- Q2. Modify Q1 logic to show the answer using SELECT with alias TOTAL_SUM.
-- TODO:


-- Q3. Declare @CustomerName VARCHAR(50), store your name in it,
-- and print: Customer name is <your name>
-- Hint: use + for concatenation.
-- TODO:


-- Q4. Declare @Balance MONEY and assign 12345.50.
-- Print it with message: Current balance is <value>
-- Hint: CAST the money value to VARCHAR before concatenation.
-- TODO:


/*
==================================================
Level 2 - Replacement And Scope
==================================================
*/

-- Q5. Declare @Score INT.
-- Set it to 40 and print it.
-- Set it again to 95 and print it.
-- In a comment, explain whether @Score contains one value or two values at the end.
-- TODO:


-- Q6. Write a comment explaining why this statement fails if it is executed alone:
-- SET @Score = 100;
-- TODO:


/*
==================================================
Level 3 - Reading Table Data Into Variables
==================================================
*/

-- Q7. Declare @AccountID INT, @Name VARCHAR(50), and @Balance MONEY.
-- Assign @AccountID = 101.
-- Use SELECT to load CUST_NAME and CBAL from dbo.TSQL_ACCOUNT_MASTER
-- into @Name and @Balance for that account.
-- Print a readable message with name and balance.
-- TODO:


-- Q8. Declare @ProductName VARCHAR(80), @Price MONEY.
-- Load product id 3 from dbo.TSQL_PRODUCT_MASTER into the variables.
-- Return them using SELECT with aliases PRODUCT_NAME and PRODUCT_PRICE.
-- TODO:


/*
==================================================
Level 4 - PRINT Vs SELECT
==================================================
*/

-- Q9. Write one PRINT statement that says Program started.
-- Then write one SELECT statement that returns all active accounts.
-- TODO:


-- Q10. In a comment, explain where PRINT output appears
-- and where SELECT output appears in SQL Server Management Studio.
-- TODO:


/*
==================================================
Level 5 - System Values
==================================================
*/

-- Q11. Select @@VERSION with alias SQL_SERVER_VERSION.
-- TODO:


-- Q12. Run a SELECT from dbo.TSQL_ACCOUNT_MASTER where STATUS = 'A'.
-- Immediately after that, select @@ROWCOUNT with alias ACTIVE_ROW_COUNT.
-- TODO:


/*
==================================================
Level 6 - Stored Procedure Without Parameters
==================================================
*/

-- Q13. Create a procedure named dbo.usp_tsql_practice_print_welcome.
-- It should print: Welcome to T-SQL programming
-- Then execute it.
-- TODO:


-- Q14. Create a procedure named dbo.usp_tsql_practice_account_count.
-- It should return the number of rows in dbo.TSQL_ACCOUNT_MASTER
-- with alias ACCOUNT_COUNT.
-- Then execute it.
-- TODO:


/*
==================================================
Level 7 - Stored Procedure With Input Parameters
==================================================
*/

-- Q15. Create OR ALTER a procedure named dbo.usp_tsql_practice_multiply.
-- It should accept @A INT and @B INT.
-- It should return @A * @B as MULTIPLICATION_RESULT.
-- Execute it with 8 and 9.
-- Execute it again with 12 and 15.
-- TODO:


-- Q16. Create OR ALTER a procedure named dbo.usp_tsql_practice_accounts_by_city.
-- It should accept @City VARCHAR(30).
-- It should return ACID, CUST_NAME, CITY, CBAL from dbo.TSQL_ACCOUNT_MASTER
-- for the supplied city.
-- Execute it for Hyderabad and Mumbai.
-- TODO:


-- Q17. Create OR ALTER a procedure named dbo.usp_tsql_practice_products_by_stock.
-- It should accept @MinimumStock INT.
-- It should return products where STOCK_QTY >= @MinimumStock.
-- Execute it with 20.
-- TODO:


/*
==================================================
Level 8 - Procedure Call Rules
==================================================
*/

-- Q18. Execute dbo.usp_tsql_practice_accounts_by_city using EXEC.
-- Then write a commented invalid example showing how NOT to call a stored procedure
-- as if it were a table.
-- TODO:


-- Q19. In a comment, explain why a stored procedure is useful
-- when a user chooses a value from a website dropdown.
-- TODO:


/*
==================================================
Level 9 - Cleanup
==================================================
*/

-- Q20. Drop only the practice procedures created in this file.
-- Keep this section commented until you finish practicing.
-- TODO:
