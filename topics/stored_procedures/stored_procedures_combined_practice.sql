USE company;
GO

/*
Stored Procedures Combined Practice

Run stored_procedures_combined_setup.sql first.
Read stored_procedures_combined_revision_notebook.md before solving this.

Questions here practice the same concepts as the stored procedure transcripts,
but the exact questions are different from the notebook examples.
*/

/*
============================================================
LEVEL 1: BASIC STORED PROCEDURES
============================================================
*/

-- Q1. Create dbo.usp_sp_list_active_accounts.
-- Return ACID, NAME, BRID, PID, CBAL for accounts where STATUS = 'A'.


-- Q2. Execute dbo.usp_sp_list_active_accounts.


-- Q3. Create dbo.usp_sp_accounts_by_product with input parameter @PID CHAR(2).
-- Return ACID, NAME, PID, CBAL for that product.


-- Q4. Execute dbo.usp_sp_accounts_by_product for product SB using positional parameter style.


-- Q5. Execute dbo.usp_sp_accounts_by_product for product CA using named parameter style.


-- Q6. Alter dbo.usp_sp_accounts_by_product so @PID has default value 'SB'.


-- Q7. Execute dbo.usp_sp_accounts_by_product without passing any value.


-- Q8. Create dbo.usp_sp_print_account_line with @ACID INT.
-- Print one line: Account <ACID> belongs to <NAME> with balance INR <CBAL>.


-- Q9. Add IF EXISTS validation to dbo.usp_sp_print_account_line.
-- If account does not exist, print 'Account not found'.


-- Q10. Use sp_help on SP_TXN_MASTER.


/*
============================================================
LEVEL 2: PARAMETERS, OUTPUT PARAMETERS, RETURN CODES
============================================================
*/

-- Q11. Create dbo.usp_sp_account_summary_output.
-- Input: @ACID INT.
-- Output: @CustomerName VARCHAR(40), @ProductID CHAR(2), @ClearBalance MONEY.
-- Assign values into output parameters.


-- Q12. Call dbo.usp_sp_account_summary_output for ACID 102.
-- Declare caller-side variables and display them.


-- Q13. In comments, explain what happens if OUTPUT is missing in the procedure call.


-- Q14. Create dbo.usp_sp_branch_totals_output.
-- Input: @BRID CHAR(3) = 'BR1'.
-- Output: @AccountCount INT, @TotalBalance MONEY.
-- Return the count and total CBAL for that branch.


-- Q15. Call dbo.usp_sp_branch_totals_output twice:
-- once with BR2, once without branch value.


-- Q16. Create dbo.usp_sp_validate_product_return.
-- Input: @PID CHAR(2).
-- Return 0 if product exists in SP_PRODUCT_MASTER.
-- Return 1 if it does not.


-- Q17. Call dbo.usp_sp_validate_product_return and capture the return code.


-- Q18. Create dbo.usp_sp_customer_status_return.
-- Input: @ACID INT.
-- Return 0 for active account, 1 for account not found, 2 for inactive/closed account.


/*
============================================================
LEVEL 3: TEMP TABLES, LOOPS, PRINT REPORTS
============================================================
*/

-- Q19. Create dbo.usp_sp_print_branch_accounts.
-- Input: @BRID CHAR(3) = 'BR1'.
-- Store accounts from that branch in a temp table with ROW_NUMBER.
-- Loop through the temp table and PRINT row number, account name, and balance.


-- Q20. Create dbo.usp_sp_transaction_type_counts.
-- Input: @ACID INT.
-- Print total transactions, CD count, CW count, and CQD count for that account.


-- Q21. Create dbo.usp_sp_current_month_transactions.
-- Input: @ACID INT.
-- Print transactions from the current month only.
-- Use a dynamic current-month date range.


-- Q22. Create dbo.usp_sp_previous_month_transaction_summary.
-- Input: @ACID INT = 101.
-- Print dynamic previous month label and total transaction amount by transaction type.


-- Q23. Create dbo.usp_sp_accounts_below_min_balance.
-- Print account name, product name, CBAL, and MIN_BAL for accounts below product minimum balance.


-- Q24. Create dbo.usp_sp_print_top_balances.
-- Input: @TopN INT = 3.
-- Use a temp table or derived table with DENSE_RANK.
-- Print all accounts whose dense rank is <= @TopN by CBAL descending.


/*
============================================================
LEVEL 4: BUSINESS-STYLE STORED PROCEDURES
============================================================
*/

-- Q25. Create dbo.usp_sp_monthly_branch_statement.
-- Inputs: @BRID CHAR(3), @MonthStart DATE.
-- Print branch name, date range, total transactions, total deposits, total withdrawals.
-- Use @MonthStart to calculate the month end range.


-- Q26. Create dbo.usp_sp_student_course_report.
-- Inputs: @StudentID INT, @DateFrom DATE, @DateTo DATE = NULL.
-- If @DateTo is NULL, use today's date.
-- Return student name, course name, enrollment date, fee paid, and grade.
-- If no enrollment exists, print a clear message.


-- Q27. Create dbo.usp_sp_product_balance_report.
-- Input: @PID CHAR(2) = 'SB'.
-- Validate product exists.
-- Return product name, account count, total balance, average balance.
-- Return 0 on success and 1 on invalid product.


-- Q28. Create dbo.usp_sp_loan_emi_schedule.
-- Inputs: @LoanAmount MONEY, @ROI DECIMAL(5,2), @TenureYears TINYINT.
-- Validate that loan amount and tenure are greater than zero.
-- Print month number, EMI date, and EMI amount.


-- Q29. Create dbo.usp_sp_account_activity_score.
-- Input: @ACID INT.
-- Output: @ActivityType VARCHAR(20).
-- If transaction count is 0, output 'No Activity'.
-- If 1 to 2, output 'Low Activity'.
-- Else output 'High Activity'.


-- Q30. Create dbo.usp_sp_transfer_amount.
-- Inputs: @FromACID INT, @ToACID INT, @Amount MONEY.
-- Validate both accounts exist and from-account has enough CBAL.
-- Subtract from one account and add to the other.
-- Return clear status codes.


/*
============================================================
LEVEL 5: ERROR HANDLING AND LOGGING
============================================================
*/

-- Q31. Create dbo.usp_sp_divide_amounts.
-- Inputs: @X INT, @Y INT.
-- Use TRY/CATCH.
-- If successful, SELECT @X / @Y.
-- If failed, log ERROR_* details into SP_SQL_LOGS and RETURN 1.


-- Q32. Execute dbo.usp_sp_divide_amounts with 100, 5 and 100, 0.
-- Select latest rows from SP_SQL_LOGS.


-- Q33. Add TRY/CATCH logging to dbo.usp_sp_loan_emi_schedule.
-- If tenure is zero, force a handled error or return a failure code before division.


-- Q34. Create dbo.usp_sp_safe_cash_withdrawal.
-- Inputs: @ACID INT, @Amount MONEY.
-- Use TRY/CATCH.
-- Return 1 if account missing.
-- Return 2 if insufficient balance.
-- Return 0 if withdrawal succeeds.
-- Log unexpected errors.


-- Q35. Write a small @@ERROR demo:
-- Perform an UPDATE statement, immediately store @@ERROR in a variable, and print/select it.
-- Add a comment explaining why @@ERROR must be checked immediately.


/*
============================================================
LEVEL 6: EXECUTION PLAN CACHE, RECOMPILE, ENCRYPTION, NESTING
============================================================
*/

-- Q36. Create dbo.usp_sp_recompile_demo that selects accounts by @BRID.
-- Add WITH RECOMPILE in the procedure definition.


-- Q37. Execute an existing procedure WITH RECOMPILE.


-- Q38. Run sp_recompile for one practice stored procedure.


-- Q39. In comments, explain when recompilation can help and when it is not enough.


-- Q40. Keep a WITH ENCRYPTION example commented only.
-- Add a comment explaining why source code backup is required before encryption.


-- Q41. Create dbo.usp_sp_child_message that prints a message.
-- Create dbo.usp_sp_parent_message that calls child.
-- Execute parent.


-- Q42. Create dbo.usp_sp_nestlevel_demo that prints @@NESTLEVEL.
-- Call it from another procedure and observe the printed level.


-- Q43. In comments, explain direct recursion and indirect recursion.
-- Mention the 32-level nesting limit.


/*
============================================================
LEVEL 7: STORED PROCEDURE TYPES AND SECURITY
============================================================
*/

-- Q44. In comments, explain user-defined stored procedures with one example from your practice.


-- Q45. Use sp_helptext on one procedure you created.


-- Q46. Use sp_helpdb and sp_help on a setup table.


-- Q47. Keep extended stored procedure examples commented:
-- EXEC xp_msver;
-- EXEC xp_fixeddrives;
-- EXEC xp_cmdshell 'dir';
-- Add a warning explaining why these are security-sensitive.


-- Q48. In comments, explain CLR stored procedures and why normal SQL developers usually create T-SQL procedures instead.


-- Q49. In comments, explain authentication vs authorization in SQL Server.


-- Q50. In comments, write sample GRANT, DENY, and REVOKE EXECUTE statements for one procedure.


/*
============================================================
MIXED INTERVIEW PRACTICE
============================================================
*/

-- Q51. Create dbo.usp_sp_branch_product_dashboard.
-- Input: @BRID CHAR(3) = NULL.
-- If @BRID is NULL, return all branches.
-- Otherwise return only that branch.
-- Output columns: branch name, product name, account count, total balance.
-- Use TRY/CATCH and return status code.


-- Q52. Create dbo.usp_sp_customer_monthly_activity.
-- Inputs: @ACID INT, @Year INT, @Month INT.
-- Output parameters: @TxnCount INT, @DepositTotal MONEY, @WithdrawalTotal MONEY.
-- Return 0 success, 1 invalid account, 2 error.


-- Q53. Create dbo.usp_sp_school_summary_output.
-- Input: @StudentID INT.
-- Output: @StudentName VARCHAR(40), @CourseCount INT.
-- Return 1 if student not found.


-- Q54. Create dbo.usp_sp_error_log_report.
-- Input: @ProcedureName VARCHAR(128) = NULL.
-- If NULL, show all logs.
-- Else show logs for that procedure only.


-- Q55. Create dbo.usp_sp_find_duplicate_balances.
-- Return balances shared by more than one account and count of accounts.
-- Then create another procedure that calls it.


/*
============================================================
RAPID REVISION QUESTIONS
Answer in comments.
============================================================
*/

-- R1. What is a stored procedure?

-- R2. Why are stored procedures used?

-- R3. What is authentication?

-- R4. What is authorization?

-- R5. What is deferred name resolution?

-- R6. Can a stored procedure call a view?

-- R7. Can a view call a stored procedure?

-- R8. Can a function call a stored procedure?

-- R9. What is an input parameter?

-- R10. What is an output parameter?

-- R11. Where do parameters appear in procedure syntax?

-- R12. Where do local variables appear?

-- R13. What keyword is needed in both definition and call for output parameters?

-- R14. What does RETURN 0 usually mean?

-- R15. What should return codes not be used for?

-- R16. Where should IF EXISTS be placed?

-- R17. Why do we use CAST/CONVERT with PRINT?

-- R18. Why should monthly statements avoid hard-coded dates?

-- R19. Why use a temp table in a complex report procedure?

-- R20. Why use ROW_NUMBER before looping rows?

-- R21. What does TRY do?

-- R22. What does CATCH do?

-- R23. Name six ERROR_* functions.

-- R24. Why is TRY/CATCH cleaner than @@ERROR checks?

-- R25. What is execution plan caching?

-- R26. What does recompile do?

-- R27. Name three ways to recompile a stored procedure.

-- R28. What does WITH ENCRYPTION do?

-- R29. Why save source code before encryption?

-- R30. What is @@NESTLEVEL?

-- R31. What is the maximum stored procedure nesting level mentioned in the lesson?

-- R32. What are system stored procedures?

-- R33. What are extended stored procedures?

-- R34. What are CLR stored procedures?

-- R35. Why are xp_cmdshell-style procedures security-sensitive?

/*
============================================================
COVERAGE CHECKLIST
============================================================
[ ] Stored procedure purpose and advantages
[ ] Security: authentication and authorization
[ ] GRANT / DENY / REVOKE concept
[ ] Stored procedure vs view/function
[ ] Deferred name resolution
[ ] CREATE / ALTER / EXEC syntax
[ ] Input parameters
[ ] Default parameter values
[ ] Output parameters
[ ] Caller-side output variables
[ ] Parameters vs variables
[ ] IF EXISTS validation
[ ] PRINT formatting
[ ] CAST / CONVERT / SPACE in reports
[ ] Bank statement procedure logic
[ ] Previous month dynamic date logic
[ ] Temp tables and ROW_NUMBER for loops
[ ] WHILE loops
[ ] Running balance logic
[ ] School enrollment procedure
[ ] Loan statement procedure
[ ] Return codes
[ ] @@ERROR
[ ] TRY/CATCH
[ ] ERROR_* functions
[ ] Error log table
[ ] Execution plan cache
[ ] Recompile options
[ ] WITH ENCRYPTION
[ ] Debugging concept
[ ] Nesting and recursion
[ ] Stored procedure types
*/
