USE company;
GO

/*
============================================================
COMBINED STORED PROCEDURES WORKBOOK
Transcripts combined:
- 14 SQL Server - Security and Stored Procedures with Execution Plan Cache
- 15 SQL Server - Complex Stored Procedures - IBank Case Study Part1
- 16 SQL Server - IBank Case Study Part2 and School SP and Loan Statement Stored Procedures
- 17 SQL Server - Debugging Stored Procedures
- 18 SQL Server - Output Parameters and Exception Handling
- 19_transcript: execution plan cache, input/default parameters, recompilation, performance troubleshooting
- 20_transcript: types of stored procedures

Run stored_procedures_combined_setup.sql first.
Do not skip the notes. Many points are direct interview traps from the trainer.
============================================================

1. LESSON TITLE
Combined SQL Server Stored Procedures: security, execution plans, complex SPs,
debugging, output parameters, return codes, exception handling, recompilation,
and SP types.

============================================================
2. CURRENT LESSON TOPICS FROM TRANSCRIPTS
============================================================
1. Stored procedure as a SQL Server database object.
2. Why stored procedures are used: centralization, reuse, maintenance, reduced network traffic, security, execution plan caching.
3. Security basics: authentication vs authorization.
4. Object permissions: GRANT, DENY, REVOKE; permissions can be applied to DB objects.
5. Stored procedures vs views/functions.
6. Deferred name resolution for stored procedures.
7. Local and global temporary stored procedures.
8. What can be written inside a stored procedure: SQL, T-SQL, variables, IF/ELSE, WHILE, temp tables, table variables, DDL, DML, calls to views/functions/SPs.
9. Caller/callee interview matrix: view, function, stored procedure.
10. SP limitations: cannot be called like a table expression in normal SELECT/INSERT/UPDATE/DELETE syntax.
11. WITH ENCRYPTION and why source code backup is required before encrypting.
12. Execution plan creation and caching.
13. What SQL Server checks during first execution: referenced objects, data type compatibility, data volume, indexes, operators, joins, unions, GROUP BY, ORDER BY.
14. Why later executions can be faster: cached plan reuse.
15. Recompilation: why, when, and who can trigger it.
16. Recompile options: create/alter WITH RECOMPILE, EXEC proc WITH RECOMPILE, sp_recompile.
17. Performance troubleshooting when recompile is not enough: isolate slow query, inspect indexes, involve DBA/network/hardware teams when needed.
18. SP nesting, @@NESTLEVEL, direct recursion, indirect recursion, 32-level nesting limit.
19. Complex banking stored procedure: previous month statement.
20. Getting previous month transactions using DATEDIFF(MONTH, DOT, GETDATE()) = 1.
21. Dynamic previous month date label using GETDATE, DATEADD, DATENAME, EOMONTH, SUBSTRING, CONVERT.
22. Print formatting with PRINT, concatenation, CAST/CONVERT, SPACE.
23. Variables can hold one value; SELECT can return many rows.
24. Temporary table for storing previous month transaction rows.
25. ROW_NUMBER() for row-by-row looping.
26. WHILE loop: initialization, condition, action, increment.
27. Running balance logic for deposits and withdrawals.
28. Counting total transactions, cash deposits, cash withdrawals, check deposits.
29. Avoiding hard-coded dates in stored procedures.
30. Requirement analysis before coding: inputs, outputs, source tables, business formulas.
31. School enrollment stored procedure requirement.
32. Loan statement stored procedure: loan amount, ROI, tenure, interest, total amount, EMI, monthly schedule.
33. Input parameters with default values.
34. Output parameters: purpose, syntax, caller-side variables, OUTPUT keyword.
35. Difference between parameters and variables.
36. IF EXISTS validation for account/branch existence.
37. Return statement and return code: 0 for success, non-zero for failure.
38. @@ERROR legacy error checking.
39. TRY/CATCH exception handling.
40. ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(), ERROR_SEVERITY(), ERROR_STATE().
41. Error logging table for failed stored procedures.
42. Debugging stored procedures with Alt+F5 and F11 in SSMS.
43. Debugging means step-by-step troubleshooting and watching variable values.
44. Types of stored procedures: user-defined, system, extended, CLR.
45. System stored procedures: sp_help, sp_helptext, sp_helpdb; live in master but callable from user databases.
46. Extended stored procedures: xp_msver, xp_cmdshell, xp_fixeddrives, mail-related examples.
47. CLR stored procedures: SQL plus .NET code through assemblies.

============================================================
3. PREVIOUSLY COVERED TOPICS NEEDED HERE
============================================================
1. CREATE/ALTER/DROP objects.
2. SELECT, WHERE, JOIN, GROUP BY, ORDER BY.
3. Aggregate functions: COUNT, SUM.
4. CAST and CONVERT.
5. Date functions: GETDATE, DATEADD, DATEDIFF, DATENAME, EOMONTH.
6. String functions: SUBSTRING, SPACE.
7. Temporary tables and table variables.
8. CTE/ranking functions, especially ROW_NUMBER().
9. IF/ELSE and WHILE loop basics.
10. Primary key, foreign key, check constraint, identity column.
11. Index basics for performance conversations.

============================================================
4. IMPORTANT POINTS FROM TRANSCRIPTS
============================================================
1. A stored procedure is a database object. A raw query is not a database object.
2. Since SPs are objects, security can be applied to them.
3. Authentication answers "who are you?" Authorization answers "what can you do?"
4. A user may enter SQL Server but still may not have permission on a database/table/procedure.
5. Views cannot accept input parameters. Stored procedures can.
6. Views are mostly one-query objects; stored procedures can contain programming logic.
7. Stored procedures are heavily used in real projects because most business logic is centralized there.
8. First execution may be slower because SQL Server creates the plan.
9. Later executions can be faster because the plan is cached and reused.
10. Recompile deletes/removes the old plan and creates a fresh plan.
11. Recompile is one performance solution, not the final answer for every slow issue.
12. If recompile does not help, inspect individual queries and indexes.
13. Variables declared after BEGIN are internal to the procedure.
14. Parameters declared with CREATE/ALTER PROC are used to receive/send data.
15. Output parameters require caller-side variables.
16. The caller must specify OUTPUT/OUT while calling output parameters.
17. PRINT is useful for formatted text reports, but SELECT is normally better for result sets consumed by applications.
18. Complex SP coding starts with understanding domain and requirement.
19. Do not hard-code month names/dates in monthly reports.
20. Temporary tables can simplify repeated access to the same intermediate result.
21. ROW_NUMBER helps loop row by row.
22. If a nullable value participates in string concatenation, handle NULL first.
23. TRY/CATCH is the modern cleaner error handling style compared with checking @@ERROR after every statement.
24. Return code is for success/failure status, not for returning business data.
25. Business data should come through result sets or output parameters.

============================================================
5. INTERVIEW TRICKS FROM TRANSCRIPTS
============================================================
1. Can a stored procedure call a view? Yes.
2. Can a stored procedure call a function? Yes.
3. Can a stored procedure call another stored procedure? Yes.
4. Can a view call a stored procedure? No.
5. Can a function call a stored procedure? No.
6. Can a view call a function? Yes.
7. Can a function call a view? Yes.
8. Can you call a stored procedure as SELECT proc_name? No, use EXEC/EXECUTE.
9. Why are stored procedures faster after first execution? Cached execution plan.
10. What is deferred name resolution? Procedure can be created even if referenced table does not exist; error comes during execution.
11. Does view creation allow missing table references? No, trainer contrasted this with SP.
12. What happens if SP is slow suddenly after running fine for years? Old plan may be unsuitable; try recompile, then query/index analysis.
13. What does WITH ENCRYPTION do? Hides the source code; keep backup before encryption.
14. What is the nesting limit? 32 levels.
15. What is @@NESTLEVEL used for? To identify current nesting/recursion depth.
16. What are system SPs? Built-in SPs like sp_help, sp_helptext, usually in master.
17. What are extended SPs? XP procedures that can work outside normal SQL, often with OS features.
18. What is CLR SP? Stored procedure using .NET CLR code/assemblies.
19. Return 0 usually means success; non-zero usually means failure.
20. Output parameters return data from server to client; caller must bring "empty variables".

============================================================
6. COMMON MISTAKES / WARNINGS FROM TRANSCRIPTS
============================================================
1. Forgetting USE database at the top of scripts.
2. Writing a procedure without a header/comment history in real work.
3. Hard-coding previous month names and dates.
4. Forgetting CAST/CONVERT during PRINT string concatenation.
5. Forgetting OUTPUT in the caller when reading output parameters.
6. Using wrong parameter data type compared with table column data type.
7. Assuming a procedure validates object names during creation.
8. Assuming recompile fixes every slow query.
9. Encrypting an SP without saving the original source elsewhere.
10. Trying to loop rows without a row number or cursor-style mechanism.
11. Not handling NULL check numbers before concatenation.
12. Using PRINT for application data when output parameters/result sets are required.
13. Returning business data with RETURN instead of using output parameters or SELECT.
14. Thinking developers normally control production server settings. DBA team usually manages production servers.
15. Treating C drive/D drive operations as normal SQL. Extended/CLR procedures are needed for outside-SQL work.

============================================================
7. BEST PRACTICES / PRACTICAL TIPS FROM TRANSCRIPTS
============================================================
1. Start scripts with USE database and GO.
2. Add SP header: name, author, creation date, purpose, database, modification history.
3. Ask for clear requirements: input parameters, output format, source tables, validation rules.
4. Use table column data types as reference for parameter/variable data types.
5. Use IF EXISTS for validation before returning data.
6. Use TRY/CATCH and log errors into a table.
7. Use output parameters when the client needs scalar values.
8. Use return codes for success/failure communication.
9. Use temp tables for intermediate data you need more than once inside a procedure.
10. Build complex procedures step by step: header, parameters, variables, validation, data collection, loop/logic, output, error handling.
11. Debug slow or incorrect SPs step by step.
12. When performance is poor, test each query inside the SP separately.
13. Know indexes well because SP performance often depends on underlying query/index design.
14. Practice case studies; SP writing depends on domain understanding plus SQL/T-SQL.

============================================================
8. SQL RULES / QUERY RULES / INTERVIEW RULES
============================================================
1. Syntax: CREATE PROC proc_name [parameters] AS BEGIN statements END.
2. Syntax: ALTER PROC proc_name [parameters] AS BEGIN statements END.
3. Call syntax: EXEC proc_name parameter_values.
4. Named parameter call syntax: EXEC proc_name @ParamName = value.
5. Input parameter default syntax: @Param datatype = default_value.
6. Output parameter definition syntax: @Param datatype OUTPUT.
7. Output parameter call rule: caller variable must be declared and passed with OUTPUT.
8. Parameters are declared before AS; local variables are declared after BEGIN.
9. Local variable assignment can use SET or SELECT.
10. String concatenation with non-string values requires CAST/CONVERT.
11. PRINT accepts a string expression; convert dates/numbers before concatenating.
12. A variable holds one value at a time; it cannot hold a full multi-row result set.
13. Use temporary table/table variable when intermediate multi-row data is needed.
14. ROW_NUMBER() requires OVER(ORDER BY ...).
15. WHILE loop needs initialization, condition, action, and increment/decrement.
16. NULL in concatenation can make the full expression NULL; handle with ISNULL/COALESCE.
17. Stored procedures support deferred name resolution; views do not in the same way.
18. Stored procedures can call views, functions, and other stored procedures.
19. Views and functions cannot call stored procedures.
20. Stored procedures cannot normally be used like SELECT stored_proc_name.
21. Maximum nesting for stored procedures is 32 levels.
22. @@ERROR returns 0 when the previous statement succeeds; non-zero when it fails.
23. TRY block contains code that may fail; CATCH block handles/logs the failure.
24. ERROR_* functions are available inside CATCH.
25. RETURN 0 usually means success; RETURN non-zero usually means failure.
26. WITH ENCRYPTION hides the stored procedure text.
27. WITH RECOMPILE creates a fresh plan rather than reusing the old cached plan.
28. sp_recompile marks an SP/table so related plans are recompiled on next run.
29. DATEDIFF(MONTH, DOT, GETDATE()) = 1 returns rows whose month boundary difference from today is 1; be careful with exact business date ranges in real systems.
30. EOMONTH(DATEADD(MONTH, -1, GETDATE())) gives the last date of previous month.
31. Security rule: GRANT allows permission, DENY blocks permission, REVOKE removes a previous GRANT/DENY.
32. Security rule: EXECUTE permission is needed to run a stored procedure when the user does not otherwise have enough rights.
33. Temporary procedure syntax uses #proc_name for local temporary procedure and ##proc_name for global temporary procedure.
34. Local temporary procedures are visible only in the creating session; global temporary procedures are visible to other sessions while they exist.
35. System stored procedures commonly start with sp_; extended stored procedures commonly start with xp_.

============================================================
9. BEGINNER-FRIENDLY NOTES
============================================================
1. Think of a stored procedure as a saved program inside SQL Server.
2. Input parameter means the client gives data to the SP.
3. Output parameter means the SP gives scalar data back to the client.
4. Variable means temporary memory used only inside the procedure.
5. A result set is what SELECT displays.
6. PRINT is for messages/text formatting, not usually for app screens.
7. Execution plan is SQL Server's chosen route for running the query.
8. Cached plan is reused experience.
9. Recompile means throw away the old route and build a new one.
10. Debugging means running slowly line by line to find where logic breaks.

============================================================
10. SYNTAX SECTION
============================================================
*/

-- Basic stored procedure
/*
CREATE PROC dbo.usp_Name
    @InputParam INT,
    @OutputParam VARCHAR(40) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @OutputParam = NAME
    FROM dbo.SP_ACCOUNT_MASTER
    WHERE ACID = @InputParam;

    RETURN 0;
END;
GO
*/

-- Calling an output parameter
/*
DECLARE @CustomerName VARCHAR(40);
DECLARE @ReturnCode INT;

EXEC @ReturnCode = dbo.usp_Name
     @InputParam = 101,
     @OutputParam = @CustomerName OUTPUT;

SELECT @ReturnCode AS ReturnCode, @CustomerName AS CustomerName;
*/

-- TRY/CATCH logging pattern
/*
BEGIN TRY
    -- SQL/T-SQL statements
    RETURN 0;
END TRY
BEGIN CATCH
    INSERT INTO dbo.SP_SQL_LOGS
    (
        ERROR_LINE, ERROR_MESSAGE, ERROR_NUMBER, ERROR_PROCEDURE,
        ERROR_DATE_TIME, ERROR_SEVERITY, ERROR_STATE
    )
    SELECT
        ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_PROCEDURE(),
        GETDATE(), ERROR_SEVERITY(), ERROR_STATE();

    RETURN 1;
END CATCH;
*/

-- Permission examples only. Run only in a safe practice database with a real user.
/*
GRANT EXECUTE ON dbo.usp_Name TO SomeUser;
DENY EXECUTE ON dbo.usp_Name TO SomeUser;
REVOKE EXECUTE ON dbo.usp_Name FROM SomeUser;
*/

-- Temporary stored procedure examples
/*
CREATE PROC #usp_local_temp_demo
AS
BEGIN
    PRINT 'local temporary procedure';
END;
GO

CREATE PROC ##usp_global_temp_demo
AS
BEGIN
    PRINT 'global temporary procedure';
END;
GO
*/

/*
============================================================
11. LEVEL 1: BASIC QUESTIONS
============================================================
Write your answer below each question.
*/

-- Q1. Create a stored procedure dbo.usp_sp_get_all_accounts that selects all rows from SP_ACCOUNT_MASTER.
create PROCEDURE dbo.usp_sp_get_all_accounts
AS
BEGIN
     select * from SP_ACCOUNT_MASTER
END;

-- Q2. Execute dbo.usp_sp_get_all_accounts.
exec dbo.usp_sp_get_all_accounts

-- Q3. Create dbo.usp_sp_get_accounts_by_branch with input parameter @BRID CHAR(3).
-- Return accounts from that branch.
create PROCEDURE dbo.usp_sp_get_accounts_by_branch
   ( 
    @BRID CHAR(3)
   )
AS
BEGIN
    SELECT * FROM SP_ACCOUNT_MASTER WHERE BRID = @BRID
END;

-- Q4. Execute dbo.usp_sp_get_accounts_by_branch for BR1 using positional parameter style.
exec dbo.usp_sp_get_accounts_by_branch 'BR1'

-- Q5. Execute dbo.usp_sp_get_accounts_by_branch for BR2 using named parameter style.
exec dbo.usp_sp_get_accounts_by_branch @BRID = 'BR2'

-- Q6. Alter dbo.usp_sp_get_accounts_by_branch and give @BRID a default value of 'BR3'.
ALTER PROCEDURE dbo.usp_sp_get_accounts_by_branch
   ( 
    @BRID CHAR(3) = 'BR3'
   )
AS
BEGIN
    SELECT * FROM SP_ACCOUNT_MASTER WHERE BRID = @BRID
END;

-- Q7. Execute dbo.usp_sp_get_accounts_by_branch without passing a branch.
exec dbo.usp_sp_get_accounts_by_branch

-- Q8. Create dbo.usp_sp_get_customer_balance with @ACID INT.
-- Return ACID, NAME, CBAL for that account.
create PROCEDURE dbo.usp_sp_get_customer_balance
   ( 
    @ACID INT
   )
AS
BEGIN
     select ACID, NAME,CBAL from SP_ACCOUNT_MASTER where ACID = @ACID
END;

-- Q9. Add IF EXISTS validation to dbo.usp_sp_get_customer_balance.
-- If account does not exist, print 'Invalid account number'.
ALTER PROCEDURE dbo.usp_sp_get_customer_balance
   ( 
    @ACID INT
   )
AS
BEGIN
    IF EXISTS (SELECT 1 FROM SP_ACCOUNT_MASTER WHERE ACID = @ACID)
       BEGIN
           SELECT ACID, NAME, CBAL FROM SP_ACCOUNT_MASTER WHERE ACID = @ACID
       END
    ELSE
       BEGIN
           PRINT 'Invalid account number'
       END
END;


-- Q10. Use sp_help on SP_ACCOUNT_MASTER.
sp_help SP_ACCOUNT_MASTER

-- Q11. Use sp_helptext on any stored procedure you created.
exec sp_helptext dbo.usp_sp_get_customer_balance;

-- Q12. Write a query against SP_TXN_MASTER that returns only previous month transactions using DATEDIFF.


-- Q12A. In comments, write examples of GRANT, DENY, and REVOKE for EXECUTE permission on one stored procedure.


-- Q12B. In comments, explain authentication vs authorization using a SQL Server login/database permission example.


/*
============================================================
12. LEVEL 2: INTERMEDIATE QUESTIONS
============================================================
*/

-- Q13. Create dbo.usp_sp_get_customer_output.
-- Input: @ACID INT
-- Output: @CustomerName VARCHAR(40), @Balance MONEY
-- Do not SELECT the customer row. Assign values into output parameters.


-- Q14. Call dbo.usp_sp_get_customer_output for ACID 101.
-- Declare caller-side variables and display them with SELECT.


-- Q15. Repeat Q14 but intentionally omit OUTPUT in the call.
-- In a comment, explain what goes wrong.


-- Q16. Create dbo.usp_sp_get_branch_summary with @BRID CHAR(3).
-- Return total accounts and total current balance for the branch.


-- Q17. Add default value 'BR1' to dbo.usp_sp_get_branch_summary.


-- Q18. Create a procedure that prints account details in one line:
-- Account: 101     Name: Billion Rao     Balance: INR 15000.00
-- Use PRINT, CAST/CONVERT, and SPACE.


-- Q19. Create a temp table #PrevMonthTxns manually using SELECT INTO from previous month transactions for ACID 101.


-- Q20. Select from #PrevMonthTxns and include ROW_NUMBER over DOT.


-- Q21. Write a WHILE loop that prints numbers 1 to 5.


-- Q22. Write a WHILE loop over #PrevMonthTxns using a row number and print one transaction per row.


-- Q23. Count total previous month transactions for account 101.


-- Q24. Count previous month CD, CW, and CQD transactions for account 101 in one query.


-- Q25. Use EOMONTH and DATEADD to display the last date of the previous month.


-- Q26. Use DATENAME and SUBSTRING to display the first three letters of the previous month name.


/*
============================================================
13. LEVEL 3: INTERVIEW-STYLE QUESTIONS
============================================================
*/

-- Q27. In comments, explain deferred name resolution.
-- Then create a procedure that references a table dbo.Table_Not_Created_Yet.
-- Do not execute it.


-- Q28. Try to create a view that references dbo.Table_Not_Created_Yet.
-- Keep it commented if it fails, and explain the difference from stored procedure creation.


-- Q29. In comments, answer:
-- Can a stored procedure call a view?
-- Can a view call a stored procedure?
-- Can a function call a stored procedure?
-- Can a stored procedure call a function?


-- Q30. Create dbo.usp_sp_child that prints 'child called'.
-- Create dbo.usp_sp_parent that executes dbo.usp_sp_child.
-- Execute parent.


-- Q31. In comments, explain direct recursion and indirect recursion.
-- Also mention the 32 nesting level limit.


-- Q32. Create a procedure with WITH ENCRYPTION in commented form only.
-- Add a comment explaining why you must save source code before encrypting.


-- Q33. Create a procedure with WITH RECOMPILE in commented form only.
-- Explain what recompilation does to the cached plan.


-- Q34. Execute one created procedure WITH RECOMPILE.


-- Q35. Run sp_recompile for one created procedure.


-- Q36. In comments, list what SQL Server considers when building first execution plan.


-- Q37. In comments, explain what you would do if a stored procedure is suddenly slow.


-- Q38. Write a procedure dbo.usp_sp_return_demo that returns 0 when @ACID exists and 1 when it does not.


-- Q39. Call dbo.usp_sp_return_demo and capture the return code into @RC.


-- Q40. Write a TRY/CATCH procedure dbo.usp_sp_divide_numbers with @X INT, @Y INT.
-- Return the division result using SELECT if successful.
-- Log errors into SP_SQL_LOGS and RETURN 1 if failed.


-- Q41. Execute dbo.usp_sp_divide_numbers with 10, 2 and then with 10, 0.
-- Select from SP_SQL_LOGS.


-- Q42. In comments, compare @@ERROR style error handling vs TRY/CATCH.


-- Q42A. Create a local temporary stored procedure #usp_sp_local_temp_demo that prints a message.
-- Execute it. In comments, explain its scope.


-- Q42B. Keep a global temporary stored procedure ##usp_sp_global_temp_demo in commented form.
-- In comments, explain how its scope differs from #usp_sp_local_temp_demo.


/*
============================================================
14. LEVEL 4: REAL-WORLD / BUSINESS-STYLE QUESTIONS
============================================================
*/

-- Q43. Create dbo.usp_sp_previous_month_bank_statement.
-- Input: @ACID INT = 101.
-- Requirements:
-- 1. Validate account exists.
-- 2. Print dynamic heading:
--    List of transactions from <prev month short name> 1st to <prev month end date>
-- 3. Print product, account number, customer name, branch, current balance.
-- 4. Store previous month transactions into a temp table with ROW_NUMBER.
-- 5. Loop through rows and PRINT serial number, date, txn type, check number, amount.
-- 6. Use ISNULL for check number.
-- 7. Print total transactions, CD count, CW count, CQD count.


-- Q44. Enhance dbo.usp_sp_previous_month_bank_statement with running balance logic.
-- CD and CQD add to running balance; CW subtracts from running balance.


-- Q45. Enhance dbo.usp_sp_previous_month_bank_statement to print dates where running balance drops below product MIN_BAL.


-- Q46. Create dbo.usp_sp_school_enrollment_statement.
-- Inputs: @StudentID INT, @DateFrom DATE, @DateTo DATE = NULL.
-- If @DateTo is NULL, use GETDATE().
-- Print student name, origin, student type, courses enrolled in date range ordered by course name.
-- If no enrollment exists, print 'No enrollment for the period'.


-- Q47. Create dbo.usp_sp_loan_statement.
-- Inputs: @LoanAmount MONEY, @ROI DECIMAL(5,2), @TenureYears TINYINT.
-- Use interest formula: PNR / 100.
-- Total amount = loan + interest.
-- EMI = total amount / (tenure years * 12).
-- Print month number, EMI date using DATEADD, and EMI amount.


-- Q48. Add TRY/CATCH to dbo.usp_sp_loan_statement.
-- Log errors to SP_SQL_LOGS.
-- Validate that tenure is not zero.


-- Q49. Create dbo.usp_sp_safe_withdrawal.
-- Inputs: @ACID INT, @Amount MONEY.
-- If account does not exist, RETURN 1.
-- If balance is insufficient, PRINT a message and RETURN 2.
-- Otherwise insert CW transaction, update balance, and RETURN 0.


-- Q50. Create dbo.usp_sp_deposit.
-- Inputs: @ACID INT, @Amount MONEY, @TxnType CHAR(3) = 'CD', @ChqNo INT = NULL.
-- Allow only CD and CQD. Update CBAL for CD only; update UBAL for CQD.


/*
============================================================
15. LEVEL 5: RAPID REVISION QUESTIONS
============================================================
Answer in comments, quickly.
*/

-- Q51. What is a stored procedure?

-- Q52. Why are stored procedures reusable?

-- Q53. What is authentication?

-- Q54. What is authorization?

-- Q55. What is deferred name resolution?

-- Q56. What is an input parameter?

-- Q57. What is an output parameter?

-- Q58. What keyword must be used while calling an output parameter?

-- Q59. What does RETURN 0 usually mean?

-- Q60. What does non-zero return usually mean?

-- Q61. What does TRY block do?

-- Q62. What does CATCH block do?

-- Q63. Name three ERROR_* functions.

-- Q64. What does WITH ENCRYPTION do?

-- Q65. What does WITH RECOMPILE do?

-- Q66. What is sp_recompile used for?

-- Q67. Can a view call a stored procedure?

-- Q68. Can a stored procedure call another stored procedure?

-- Q69. What is the maximum nesting level?

-- Q70. What are system stored procedures?

-- Q71. What are extended stored procedures?

-- Q72. What are CLR stored procedures?

-- Q73. Why should you avoid hard-coded dates in monthly SPs?

-- Q74. Why do we use ROW_NUMBER before looping transaction rows?

-- Q75. Why should parameter data type match table column data type?

/*
============================================================
16. MIXED INTERVIEW PRACTICE
============================================================
*/

-- Q76. Build one stored procedure dbo.usp_sp_branch_transaction_report.
-- Input: @BRID CHAR(3) = 'BR1'
-- Output parameters: @TxnCount INT OUTPUT, @TotalAmount MONEY OUTPUT
-- Result set: transaction type wise count and total amount.
-- Add IF EXISTS validation for branch.
-- Add TRY/CATCH logging.
-- Return 0 success, 1 invalid branch, 2 error.


-- Q77. Call dbo.usp_sp_branch_transaction_report with output variables and return code.


-- Q78. Create a procedure that creates a local temp table inside it.
-- Execute it.
-- In comments, explain when the temp table is removed.


-- Q79. Create a procedure that calls two other procedures directly.
-- In comments, explain why this is not the same as 32-level nesting.


-- Q80. Write comments explaining the difference between:
-- user-defined SP, system SP, extended SP, CLR SP.


-- Q81. Show examples of system stored procedures:
-- sp_help, sp_helptext, sp_helpdb.


-- Q82. Keep these extended SP examples commented:
-- EXEC xp_msver;
-- EXEC xp_fixeddrives;
-- EXEC xp_cmdshell 'dir';
-- Add a warning comment about permissions/security.


-- Q83. Write a performance troubleshooting note:
-- SP slow -> recompile -> still slow -> extract each query -> test -> inspect indexes/table/data volume -> involve DBA if server/resource issue.


-- Q84. Write a short note explaining why xp_cmdshell and other extended stored procedures are security-sensitive.


-- Q85. Write a short note explaining why most SQL developers mainly create user-defined stored procedures, not CLR stored procedures.


/*
============================================================
17. OPTIONAL CHALLENGE QUESTIONS
============================================================
*/

-- C1. Rewrite previous month transaction filtering using an exact date range:
-- DOT >= first day of previous month AND DOT < first day of current month.
-- Explain why this is usually safer than DATEDIFF on the column.


-- C2. Create dbo.usp_sp_account_monthly_summary.
-- Inputs: @ACID INT, @MonthStart DATE.
-- Output parameters: @OpeningBalance MONEY, @ClosingBalance MONEY, @TxnCount INT.
-- Return status codes for invalid account and errors.


-- C3. Create a recursive stored procedure that stops when @@NESTLEVEL reaches 5.
-- Keep it safe and do not allow infinite recursion.


-- C4. Add a nonclustered index on SP_TXN_MASTER(ACID, DOT).
-- Re-run previous month query and explain in comments why this index may help.


-- C5. Create a procedure that intentionally fails and writes to SP_SQL_LOGS.
-- Then write a query to show latest error per stored procedure.


/*
============================================================
18. TRANSCRIPT COVERAGE CHECKLIST
============================================================
Current transcript topics covered:
[ ] Stored procedure definition and advantages
[ ] Security: authentication vs authorization
[ ] DB objects and permissions: GRANT/DENY/REVOKE concept
[ ] Stored procedure vs view/function limitations
[ ] Deferred name resolution
[ ] Temporary stored procedures concept
[ ] CREATE/ALTER/EXEC syntax
[ ] Input parameters and default values
[ ] Output parameters and caller variables
[ ] Parameters vs variables
[ ] PRINT formatting with CAST/CONVERT/SPACE
[ ] IF EXISTS validation
[ ] Complex bank statement SP
[ ] Previous month transaction logic
[ ] Dynamic previous month heading
[ ] Temp table and ROW_NUMBER for looping
[ ] WHILE loop row-by-row printing
[ ] Running balance logic
[ ] Transaction counts by type
[ ] School enrollment SP requirement
[ ] Loan statement SP requirement
[ ] Business formula handling
[ ] Debugging with Alt+F5 and F11
[ ] Execution plan creation and cache
[ ] Recompile options and troubleshooting
[ ] Nesting, recursion, @@NESTLEVEL, 32-level limit
[ ] Return codes
[ ] @@ERROR legacy handling
[ ] TRY/CATCH modern error handling
[ ] ERROR_* functions
[ ] Error log table
[ ] User-defined stored procedures
[ ] System stored procedures
[ ] Extended stored procedures
[ ] CLR stored procedures

Previous topics reused for revision/practice:
[ ] SELECT/WHERE/JOIN/GROUP BY/ORDER BY
[ ] Aggregate functions
[ ] CAST/CONVERT
[ ] Date functions
[ ] String functions
[ ] Temp tables/table variables
[ ] ROW_NUMBER
[ ] IF/ELSE and WHILE
[ ] Index basics

Future/mentioned but not deeply taught here:
[ ] Cursors inside stored procedures
[ ] Full trigger implementation from IBank case study
[ ] Deep index/performance tuning
[ ] DBA high availability implementation
[ ] CLR assembly creation details
[ ] Production security administration details

Setup file created:
[x] stored_procedures_combined_setup.sql

Important transcript points not always turned into direct coding questions:
[ ] Developers commonly spend a large portion of SQL project time on stored procedures.
[ ] Domain understanding is required before writing complex SPs.
[ ] Training is where mistakes should be practiced before real projects.
[ ] DBA, network, hardware, and application teams may all be involved in production performance issues.
[ ] Keep a clean modification history in real stored procedure scripts.
*/
