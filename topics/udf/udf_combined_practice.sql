USE company;
GO

/*
UDF Combined Practice

Run order:
1. Run udf_combined_setup.sql.
2. Read udf_combined_revision_notebook.md.
3. Solve this practice file.

The concepts match the lessons, but the questions are different.
For CREATE FUNCTION answers, keep GO before and after the function body.
*/

/*
==================================================
Level 1 - Scalar Functions
==================================================
*/

-- Q1. Create a scalar function dbo.udf_practice_square.
-- It should accept @Number INT and return @Number * @Number.
-- Then call it for 9.
-- TODO:


-- Q2. Create a scalar function dbo.udf_practice_balance_status.
-- It should accept @Balance MONEY and return VARCHAR(20):
-- 'HIGH' when balance >= 30000
-- 'MEDIUM' when balance >= 10000
-- otherwise 'LOW'
-- Then call it using rows from dbo.UDF_ACCOUNT_MASTER.
-- TODO:


-- Q3. Create a scalar function dbo.udf_practice_total_pay.
-- It should accept @BasicPay, @Allowance, @Bonus, @Deductions as MONEY.
-- Return @BasicPay + @Allowance + @Bonus - @Deductions.
-- Then use it in a SELECT from dbo.UDF_EMPLOYEE_PAY with a fixed bonus of 1000.
-- TODO:


/*
==================================================
Level 2 - Function Calls In SQL Statements
==================================================
*/

-- Q4. Use dbo.udf_practice_balance_status in a WHERE clause.
-- Return accounts whose status from the function is 'HIGH'.
-- TODO:


-- Q5. Insert a new account into dbo.UDF_ACCOUNT_MASTER.
-- Use dbo.udf_get_customer_balance_lesson(102) as the new account balance.
-- Use ACID = 301.
-- TODO:


-- Q6. Delete ACID = 301 after verifying it was inserted.
-- TODO:


/*
==================================================
Level 3 - Inline Table-Valued Functions
==================================================
*/

-- Q7. Create an inline table-valued function dbo.udf_practice_accounts_by_city.
-- It should accept @City VARCHAR(30).
-- It should return ACID, CUST_NAME, CITY, BRID, CBAL, STATUS from dbo.UDF_ACCOUNT_MASTER.
-- Filter by @City.
-- TODO:


-- Q8. Call dbo.udf_practice_accounts_by_city for 'Hyderabad'.
-- TODO:


-- Q9. Join dbo.udf_practice_accounts_by_city('Hyderabad') with dbo.UDF_TXN_MASTER.
-- Show ACID, CUST_NAME, TXN_TYPE, TXN_AMOUNT.
-- TODO:


/*
==================================================
Level 4 - Multi-Statement Table-Valued Functions
==================================================
*/

-- Q10. Create a multi-statement table-valued function dbo.udf_practice_account_txn_summary.
-- It should accept @MinimumBalance MONEY.
-- Return a table with:
-- ACID INT, CUST_NAME VARCHAR(50), CBAL MONEY, TXN_COUNT INT, TOTAL_TXN_AMOUNT MONEY
-- Insert accounts whose ISNULL(CBAL, 0) >= @MinimumBalance.
-- Use LEFT JOIN to include accounts with no transactions.
-- TODO:


-- Q11. Call dbo.udf_practice_account_txn_summary with 10000.
-- TODO:


/*
==================================================
Level 5 - Metadata And Source Code
==================================================
*/

-- Q12. List all user-defined functions in the current database.
-- Use sys.objects and filter types FN, IF, TF.
-- TODO:


-- Q13. Use sp_helptext to show the code of dbo.udf_practice_square.
-- TODO:


/*
==================================================
Level 6 - UDF Limitations
==================================================
*/

-- Q14. In a comment, explain why INSERT INTO dbo.UDF_ACCOUNT_MASTER
-- is not allowed inside a function body.
-- TODO:


-- Q15. In a comment, explain why #temp tables are not allowed inside functions
-- and what you can use instead.
-- TODO:


-- Q16. In a comment, explain why a stored procedure is better than a function
-- when you need to update account status and insert a transaction row.
-- TODO:


/*
==================================================
Level 7 - Seat Number Challenge
==================================================
*/

-- Q17. Create a scalar function dbo.udf_practice_next_ticket_code.
-- Use dbo.UDF_MOVIE_CUSTOMER and return the next seat number after the latest row.
-- Keep the same A1 to A12, then B1 pattern from the notebook.
-- TODO:


-- Q18. Create a procedure dbo.usp_practice_insert_movie_customer.
-- It should accept @CustomerName, @Email, @PhoneNo.
-- It should insert into dbo.UDF_MOVIE_CUSTOMER using dbo.udf_practice_next_ticket_code().
-- Then execute it twice with different customers.
-- TODO:


-- Q19. Select all rows from dbo.UDF_MOVIE_CUSTOMER to verify the generated seats.
-- TODO:


/*
==================================================
Level 8 - Cleanup
==================================================
*/

-- Q20. Drop only the practice functions/procedure created in this file.
-- Keep this section commented until you finish practicing.
-- TODO:

