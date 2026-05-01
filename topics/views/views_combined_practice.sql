USE company;
GO

/*
Views Combined Practice

Run order:
1. Run views_combined_setup.sql first.
2. Read views_combined_revision_notebook.md.
3. Solve this practice file.

Important:
- These questions practice the same concepts as the lessons.
- The exact questions are intentionally different from the notebook examples.
- Write your answer below each TODO.
- For CREATE VIEW / ALTER VIEW answers, keep GO before and after the statement
  because SQL Server expects CREATE VIEW to start its own batch.
*/

/*
==================================================
Level 1 - Basic View Creation
==================================================
*/

-- Q1. Create a view named dbo.vw_lvw_bengaluru_customers.
-- It should show ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, STATUS, and CBAL.
-- Filter only customers whose CITY is Bengaluru.
-- TODO:


-- Q2. Call dbo.vw_lvw_bengaluru_customers and sort highest balance first.
-- Remember: place ORDER BY in the outer SELECT, not inside the view definition.
-- TODO:


-- Q3. Create a view named dbo.vw_lvw_current_accounts.
-- It should show active CURRENT accounts only.
-- Columns: ACID, CUST_NAME, BRID, ACCOUNT_TYPE, STATUS, CBAL.
-- TODO:


-- Q4. Use sp_helptext to display the code of dbo.vw_lvw_current_accounts.
-- TODO:


-- Q5. List only your practice views whose name starts with vw_lvw_.
-- Use sys.views.
-- TODO:


/*
==================================================
Level 2 - Aliases, Expressions, And Constants
==================================================
*/

-- Q6. Create a view named dbo.vw_lvw_balance_categories.
-- Show ACID, CUST_NAME, CBAL, and a calculated column named BALANCE_BAND.
-- BALANCE_BAND should be:
-- 'HIGH' when CBAL >= 30000
-- 'MEDIUM' when CBAL >= 10000
-- otherwise 'LOW'
-- TODO:


-- Q7. Create a view named dbo.vw_lvw_customer_display.
-- Show ACID, CUST_NAME, EMAIL, and a constant column named SOURCE_SYSTEM
-- with value 'IBANK_LEARNING'.
-- TODO:


-- Q8. Select from dbo.vw_lvw_balance_categories and show only HIGH accounts.
-- TODO:


/*
==================================================
Level 3 - Date Logic In Views
==================================================
*/

-- Q9. Create a view named dbo.vw_lvw_last_90_days_transactions.
-- Show TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT.
-- Filter transactions from the last 90 days.
-- TODO:


-- Q10. Create a view named dbo.vw_lvw_cash_deposits_this_year.
-- Show TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT.
-- Filter current year and TXN_TYPE = 'Cash Deposit'.
-- TODO:


-- Q11. Create a view named dbo.vw_lvw_accounts_without_recent_txn.
-- Show active accounts that have no transaction in the last 120 days.
-- Use NOT EXISTS.
-- Columns: ACID, CUST_NAME, BRID, STATUS, CBAL.
-- TODO:


/*
==================================================
Level 4 - Joins With Views
==================================================
*/

-- Q12. Create a view named dbo.vw_lvw_recent_txn_with_customer.
-- Use dbo.vw_lvw_last_90_days_transactions and join dbo.ACCOUNT_MASTER_VW.
-- Show TXNID, ACID, CUST_NAME, BRID, TXN_DATE, TXN_TYPE, AMOUNT.
-- TODO:


-- Q13. Query dbo.vw_lvw_recent_txn_with_customer and join dbo.BRANCH_MASTER_VW.
-- Show TXNID, CUST_NAME, BRANCH_NAME, BRANCH_CITY, TXN_DATE, AMOUNT.
-- TODO:


-- Q14. Create a view named dbo.vw_lvw_branch2_recent_txn.
-- Build it on top of dbo.vw_lvw_recent_txn_with_customer.
-- Filter BRID = 'BR2'.
-- TODO:


/*
==================================================
Level 5 - Aggregate Views, GROUP BY, HAVING
==================================================
*/

-- Q15. Create a view named dbo.vw_lvw_account_type_summary.
-- Group by ACCOUNT_TYPE.
-- Show ACCOUNT_TYPE, ACCOUNT_COUNT, TOTAL_BALANCE, AVG_BALANCE, MIN_BALANCE, MAX_BALANCE.
-- TODO:


-- Q16. Query dbo.vw_lvw_account_type_summary and show only account types
-- where TOTAL_BALANCE is greater than 50000.
-- TODO:


-- Q17. Write one normal SELECT query, not a view.
-- Show branch-wise transaction total for current year.
-- Use WHERE before GROUP BY.
-- Use HAVING to show only branches where SUM(AMOUNT) > 5000.
-- TODO:


/*
==================================================
Level 6 - Updatable Views
==================================================
*/

-- Q18. Create a simple one-table view named dbo.vw_lvw_chennai_accounts_edit.
-- Include all required columns from dbo.ACCOUNT_MASTER_VW:
-- ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL, RMK.
-- Filter CITY = 'Chennai'.
-- TODO:


-- Q19. Insert one new Chennai account through dbo.vw_lvw_chennai_accounts_edit.
-- Use ACID = 901 and a valid BRID from the setup.
-- Then select the row from dbo.ACCOUNT_MASTER_VW.
-- TODO:


-- Q20. Update the RMK of ACID = 901 through dbo.vw_lvw_chennai_accounts_edit.
-- TODO:


-- Q21. Delete ACID = 901 through dbo.vw_lvw_chennai_accounts_edit.
-- TODO:


-- Q22. Try to explain in a SQL comment:
-- Why is dbo.vw_lvw_account_type_summary not a good view for UPDATE?
-- TODO:


/*
==================================================
Level 7 - WITH CHECK OPTION
==================================================
*/

-- Q23. Create a view named dbo.vw_lvw_active_accounts_check.
-- Include all required columns from dbo.ACCOUNT_MASTER_VW.
-- Filter STATUS = 'A'.
-- Add WITH CHECK OPTION.
-- TODO:


-- Q24. Insert ACID = 902 with STATUS = 'A' through dbo.vw_lvw_active_accounts_check.
-- Then select it from both the view and the base table.
-- TODO:


-- Q25. Try to update ACID = 902 through dbo.vw_lvw_active_accounts_check
-- and set STATUS = 'I'. This should fail because of CHECK OPTION.
-- Keep the failing statement commented after testing if you want the whole file to run.
-- TODO:


-- Q26. Clean up ACID = 902 from dbo.ACCOUNT_MASTER_VW.
-- TODO:


/*
==================================================
Level 8 - Schemas
==================================================
*/

-- Q27. Confirm that schema reporting_lvw exists.
-- If it does not exist, create it using IF NOT EXISTS.
-- TODO:


-- Q28. Create a view named reporting_lvw.vw_lvw_high_balance_accounts.
-- Show accounts where CBAL >= 30000.
-- TODO:


-- Q29. Query reporting_lvw.vw_lvw_high_balance_accounts.
-- TODO:


/*
==================================================
Level 9 - WITH SCHEMABINDING
==================================================
*/

-- Q30. Create a schemabound view named dbo.vw_lvw_schema_active_balances.
-- Use two-part table name dbo.ACCOUNT_MASTER_VW.
-- Show ACID, CUST_NAME, BRID, STATUS, CBAL.
-- Filter STATUS = 'A'.
-- TODO:


-- Q31. Write a commented statement that would fail while the schemabound view exists:
-- Example idea: ALTER TABLE dbo.ACCOUNT_MASTER_VW DROP COLUMN CBAL;
-- Do not run the destructive statement.
-- TODO:


/*
==================================================
Level 10 - WITH ENCRYPTION
==================================================
*/

-- Q32. Create a small encrypted view named dbo.vw_lvw_encrypted_demo.
-- Show ACID, CUST_NAME, BRID from dbo.ACCOUNT_MASTER_VW where BRID = 'BR3'.
-- After creating it, run sp_helptext and observe the result.
-- TODO:


-- Q33. In a comment, write why you must keep a source script before using WITH ENCRYPTION.
-- TODO:


/*
==================================================
Level 11 - Indexed View
==================================================
*/

-- Q34. Create an indexed view named dbo.vw_lvw_indexed_account_type_balance.
-- Requirements:
-- 1. Set the required indexed-view SET options.
-- 2. Use WITH SCHEMABINDING.
-- 3. Group by ACCOUNT_TYPE.
-- 4. Include COUNT_BIG(*) AS ACCOUNT_COUNT and SUM(CBAL) AS TOTAL_BALANCE.
-- 5. Create a unique clustered index on ACCOUNT_TYPE.
--
-- If your SQL Server session blocks indexed views due to settings,
-- re-run the SET options in the same query window.
-- TODO:


-- Q35. Query dbo.vw_lvw_indexed_account_type_balance.
-- TODO:


-- Q36. In a comment, explain the difference between a normal view and an indexed view.
-- TODO:


/*
==================================================
Level 12 - Cleanup Practice Objects
==================================================
*/

-- Q37. Drop all practice views you created in this file.
-- Keep this section commented until you finish practicing.
-- TODO:
