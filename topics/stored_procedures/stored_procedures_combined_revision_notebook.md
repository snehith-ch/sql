# Stored Procedures Revision Notebook

Run `stored_procedures_combined_setup.sql` first. This notebook follows the same model as the query revision notebook: lesson-style examples, readable explanations, quick revision rules, interview traps, and complete grouped notes. The practice questions are kept in a separate file: `stored_procedures_combined_practice.sql`.

The examples are based on the trainer's stored procedure transcripts: security and execution plan cache, IBank previous month statement, school enrollment statement, loan statement, debugging, output parameters, exception handling, recompilation, and stored procedure types.

Official SQL Server references used for added/verified rules: Microsoft Learn for `CREATE PROCEDURE`, parameters/output parameters/return codes, `TRY...CATCH`, `@@ERROR`, error functions, recompilation, and execution plan caching.

## Quick Revision

A stored procedure is a saved SQL Server database object used to centralize SQL and T-SQL code. It can accept input parameters, return output parameters, return result sets, return an integer return code, use variables, use `IF/ELSE`, use loops, use temp tables, call other procedures/functions/views, and handle errors.

The basic placement is:

```sql
USE company;
GO

CREATE OR ALTER PROC dbo.usp_Name
    @InputParam INT,
    @OutputParam MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- declarations, validation, business logic, result sets/output params

    RETURN 0;
END;
GO
```

Parameters are placed before `AS`. Local variables are declared after `BEGIN`. `IF EXISTS` should be placed before the action that depends on the check, such as before returning account data, before dropping an object, or before performing a withdrawal. `TRY` contains code that may fail. `CATCH` comes immediately after `END TRY` and contains error handling/logging. `RETURN 0` usually means success; non-zero return values usually mean different failure statuses.

Output parameters must be marked with `OUTPUT` in the procedure definition and also in the calling statement. The caller must declare variables first, then pass those variables with `OUTPUT`. If you forget `OUTPUT` in the call, the caller does not receive the changed value.

When a procedure is first executed, SQL Server compiles a plan. Later executions can reuse the cached plan. If the data, indexes, schema, or parameter pattern changes heavily, the old plan may become unsuitable. Recompile means remove/avoid the old cached plan and compile a fresh plan. Recompile can be done with `WITH RECOMPILE`, `EXEC proc WITH RECOMPILE`, or `sp_recompile`.

For formatted reports, the trainer uses `PRINT`, `CAST`, `CONVERT`, and `SPACE`. Remember that `PRINT` works with strings, so numbers and dates must be converted before concatenation. For application-friendly data, result sets and output parameters are usually better than long `PRINT` messages.

## Stored Procedure Purpose

The trainer explains stored procedures as SQL Server objects used to centralize code. A raw query is not something you see as a database object, but a table, view, function, trigger, and stored procedure are database objects. Because a stored procedure is an object, permissions can be applied to it.

Stored procedures are important because real projects often put a lot of business logic inside them. The trainer repeatedly says that queries, stored procedures, and indexes are the core interview and real-work areas. If queries are the foundation, stored procedures are where those queries become reusable business programs.

Common advantages:

- code is centralized
- code is reusable
- maintenance is easier
- security can be controlled
- less code needs to travel from client to server
- execution plans can be cached and reused
- complex T-SQL programming can be implemented

## Security: Authentication and Authorization

Authentication means "who are you?" In SQL Server terms, this is the first-level permission: can the user log in to the server?

Authorization means "what can you do after login?" A user may be allowed into SQL Server but may not have permission to access a particular database, table, view, or stored procedure.

The trainer's interview-friendly point is that security has two levels. Server login is not enough. After login, database-level and object-level permissions decide what the user can read, change, or execute.

Common permission ideas:

```sql
GRANT EXECUTE ON dbo.usp_SomeProcedure TO SomeUser;
DENY EXECUTE ON dbo.usp_SomeProcedure TO SomeUser;
REVOKE EXECUTE ON dbo.usp_SomeProcedure FROM SomeUser;
```

`GRANT` allows, `DENY` blocks, and `REVOKE` removes an earlier permission rule. In real projects, developers may not be the people who grant production security, but they should understand the concept.

## Stored Procedures vs Views and Functions

Views are useful for saved queries, but the trainer emphasizes their limitations. A view cannot accept input parameters like a stored procedure. A view is mostly a query object, while a stored procedure can contain SQL plus T-SQL programming logic.

Important caller/callee interview matrix:

```text
Stored procedure can call view: yes
Stored procedure can call function: yes
Stored procedure can call stored procedure: yes
View can call view: yes
View can call function: yes
View can call stored procedure: no
Function can call view: yes
Function can call function: yes
Function can call stored procedure: no
```

The trainer's simple rule is that stored procedures can call everyone, but views/functions cannot call stored procedures.

Stored procedures also have a limitation: you cannot normally call them like a table expression with `SELECT proc_name`. Use `EXEC` or `EXECUTE`.

## Deferred Name Resolution

Deferred name resolution is a major stored procedure interview point from the transcript. SQL Server can create a stored procedure even when a referenced table does not exist yet. The name error appears when the procedure is executed, not when it is created.

Lesson-style example:

```sql
CREATE OR ALTER PROC dbo.usp_sp_missing_table_demo
AS
BEGIN
    SELECT *
    FROM dbo.CustomerTable_NotCreatedYet;
END;
GO
```

The trainer contrasts this with views: creating a view on a missing table fails immediately. The reason he gives is practical project work. One developer may be building tables while other developers start procedure work from documentation, so stored procedure development can happen in parallel.

## Parameters and Variables

Parameters are declared in the procedure definition. They are used to pass data into the procedure or send data back to the caller.

Variables are declared inside the procedure after `BEGIN`. They are temporary memory holders used inside the procedure.

Input parameter:

```sql
CREATE OR ALTER PROC dbo.usp_sp_accounts_by_branch
    @BRID CHAR(3)
AS
BEGIN
    SELECT ACID, NAME, CBAL
    FROM dbo.SP_ACCOUNT_MASTER
    WHERE BRID = @BRID;
END;
GO
```

Calling with positional value:

```sql
EXEC dbo.usp_sp_accounts_by_branch 'BR1';
```

Calling with named parameter:

```sql
EXEC dbo.usp_sp_accounts_by_branch @BRID = 'BR2';
```

Input parameters can have default values:

```sql
CREATE OR ALTER PROC dbo.usp_sp_accounts_by_branch
    @BRID CHAR(3) = 'BR1'
AS
BEGIN
    SELECT ACID, NAME, CBAL
    FROM dbo.SP_ACCOUNT_MASTER
    WHERE BRID = @BRID;
END;
GO
```

If the caller supplies a value, that value is used. If the caller does not supply a value, the default is used.

## Output Parameters

Output parameters return scalar values from the procedure to the caller. The trainer explains this as the caller bringing empty bags. The procedure fills them, but the caller must bring them and must say `OUTPUT`.

Procedure definition:

```sql
CREATE OR ALTER PROC dbo.usp_sp_get_customer_output
    @ACID INT,
    @CustomerName VARCHAR(40) OUTPUT,
    @Balance MONEY OUTPUT
AS
BEGIN
    SELECT @CustomerName = NAME,
           @Balance = CBAL
    FROM dbo.SP_ACCOUNT_MASTER
    WHERE ACID = @ACID;
END;
GO
```

Calling it:

```sql
DECLARE @Name VARCHAR(40);
DECLARE @Bal MONEY;

EXEC dbo.usp_sp_get_customer_output
     @ACID = 101,
     @CustomerName = @Name OUTPUT,
     @Balance = @Bal OUTPUT;

SELECT @Name AS CustomerName, @Bal AS Balance;
```

Important rule: `OUTPUT` must be written in both places: procedure definition and procedure call.

## Return Codes

A stored procedure can return an integer return code. The trainer uses return codes to tell the caller whether the procedure succeeded or failed.

Common lesson convention:

```text
0 = success
1 = invalid input or failure
2 = another specific failure
```

Example:

```sql
CREATE OR ALTER PROC dbo.usp_sp_account_exists_return
    @ACID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.SP_ACCOUNT_MASTER WHERE ACID = @ACID)
        RETURN 0;

    RETURN 1;
END;
GO

DECLARE @RC INT;
EXEC @RC = dbo.usp_sp_account_exists_return @ACID = 101;
SELECT @RC AS ReturnCode;
```

Microsoft Learn also emphasizes that return codes are for status, not for returning application/business data. Use result sets or output parameters for data.

## IF EXISTS Validation

`IF EXISTS` checks whether a query returns at least one row. In stored procedures, it is commonly placed before the main action.

Example: validate account before returning data.

```sql
CREATE OR ALTER PROC dbo.usp_sp_get_customer_balance
    @ACID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.SP_ACCOUNT_MASTER WHERE ACID = @ACID)
    BEGIN
        SELECT ACID, NAME, CBAL
        FROM dbo.SP_ACCOUNT_MASTER
        WHERE ACID = @ACID;
    END
    ELSE
    BEGIN
        PRINT 'Invalid account number';
    END
END;
GO
```

This avoids silent empty results when the user passes a wrong account number.

## PRINT Formatting

The complex banking stored procedure uses `PRINT` to create a formatted statement. `PRINT` needs strings. If you concatenate numbers or dates, convert them first.

```sql
DECLARE @ACID INT = 101;
DECLARE @Name VARCHAR(40);
DECLARE @BRID CHAR(3);
DECLARE @Balance MONEY;

SELECT @Name = NAME,
       @BRID = BRID,
       @Balance = CBAL
FROM dbo.SP_ACCOUNT_MASTER
WHERE ACID = @ACID;

PRINT 'Account Number: ' + CAST(@ACID AS VARCHAR(20))
      + SPACE(10)
      + 'Branch: ' + @BRID;

PRINT 'Customer Name: ' + @Name
      + SPACE(10)
      + 'Balance: INR ' + CAST(@Balance AS VARCHAR(30));
```

For dates, use `CONVERT` when a specific display style is required.

```sql
PRINT 'Date: ' + CONVERT(VARCHAR(30), GETDATE(), 107);
```

## Complex Bank Statement Procedure

The IBank case study procedure accepts an account number and prints previous month transactions. Before coding, the trainer says to understand:

- input parameter
- output/report format
- source tables
- business rules
- date logic
- transaction types
- running balance logic

The lesson uses previous month filtering:

```sql
WHERE DATEDIFF(MONTH, DOT, GETDATE()) = 1
```

That matches the trainer’s example. For real systems, an exact date range is often safer:

```sql
DECLARE @StartDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0);
DECLARE @EndDate DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);

SELECT *
FROM dbo.SP_TXN_MASTER
WHERE DOT >= @StartDate
  AND DOT < @EndDate;
```

Dynamic previous month heading:

```sql
DECLARE @LastMonthName VARCHAR(20);
DECLARE @LastMonthShort VARCHAR(3);
DECLARE @LastMonthEnd DATE;

SET @LastMonthName = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE()));
SET @LastMonthShort = SUBSTRING(@LastMonthName, 1, 3);
SET @LastMonthEnd = EOMONTH(DATEADD(MONTH, -1, GETDATE()));

PRINT 'List of transactions from '
      + @LastMonthShort + ' 1st to '
      + CONVERT(VARCHAR(30), @LastMonthEnd, 107);
```

To print transactions row by row, the trainer stores previous month data in a temp table with `ROW_NUMBER()`, counts rows, and loops with `WHILE`.

```sql
SELECT ROW_NUMBER() OVER (ORDER BY DOT, TXN_ID) AS RowNo,
       DOT,
       TXN_TYPE,
       CHQ_NO,
       TXN_AMOUNT
INTO #PrevMonthTxns
FROM dbo.SP_TXN_MASTER
WHERE ACID = 101
  AND DATEDIFF(MONTH, DOT, GETDATE()) = 1;
```

The running balance logic is business logic:

```text
CD  = cash deposit, add amount
CQD = cheque deposit, add to unclear/statement logic depending on requirement
CW  = cash withdrawal, subtract amount
```

## School Enrollment Procedure

The school case study procedure accepts a student, a from date, and an optional to date. If the to date is not supplied, use current date.

Important ideas:

- `@DateFrom` is mandatory
- `@DateTo` can default to `NULL`
- if `@DateTo IS NULL`, set it to `GETDATE()`
- join student, enrollment, and course tables
- order courses by course name
- if no enrollment exists, print a message

Lesson-style skeleton:

```sql
CREATE OR ALTER PROC dbo.usp_sp_school_enrollment_statement
    @StudentID INT,
    @DateFrom DATE,
    @DateTo DATE = NULL
AS
BEGIN
    IF @DateTo IS NULL
        SET @DateTo = CAST(GETDATE() AS DATE);

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SP_ENROLLMENT_MASTER
        WHERE STUDENT_ID = @StudentID
          AND DOE BETWEEN @DateFrom AND @DateTo
    )
    BEGIN
        PRINT 'No enrollment for the period';
        RETURN;
    END;

    SELECT S.STUDENT_NAME,
           S.ORIGIN,
           S.STUDENT_TYPE,
           C.COURSE_NAME,
           E.DOE,
           E.FEE_PAID,
           E.GRADE
    FROM dbo.SP_STUDENT_MASTER AS S
    JOIN dbo.SP_ENROLLMENT_MASTER AS E
        ON S.STUDENT_ID = E.STUDENT_ID
    JOIN dbo.SP_COURSE_MASTER AS C
        ON E.COURSE_ID = C.COURSE_ID
    WHERE S.STUDENT_ID = @StudentID
      AND E.DOE BETWEEN @DateFrom AND @DateTo
    ORDER BY C.COURSE_NAME;
END;
GO
```

## Loan Statement Procedure

The loan procedure accepts loan amount, rate of interest, and tenure. The trainer uses a simple business formula:

```text
Interest = PNR / 100
Total amount = loan amount + interest
EMI = total amount / (tenure years * 12)
```

The important lesson is not banking mathematics. The important lesson is how to convert a business formula into a stored procedure with variables and a loop.

```sql
DECLARE @LoanAmount MONEY = 200000;
DECLARE @ROI DECIMAL(5,2) = 12;
DECLARE @TenureYears TINYINT = 3;
DECLARE @Interest MONEY;
DECLARE @TotalAmount MONEY;
DECLARE @EMI MONEY;
DECLARE @MonthNo INT = 1;

SET @Interest = (@LoanAmount * @ROI * @TenureYears) / 100;
SET @TotalAmount = @LoanAmount + @Interest;
SET @EMI = @TotalAmount / (@TenureYears * 12);

WHILE @MonthNo <= @TenureYears * 12
BEGIN
    PRINT CAST(@MonthNo AS VARCHAR(10))
          + SPACE(5)
          + CONVERT(VARCHAR(30), DATEADD(MONTH, @MonthNo, GETDATE()), 107)
          + SPACE(5)
          + CAST(@EMI AS VARCHAR(30));

    SET @MonthNo = @MonthNo + 1;
END;
```

Validate tenure before dividing by `@TenureYears * 12`, otherwise you can get divide-by-zero errors.

## Execution Plan Cache and Recompile

The trainer explains that the first execution of a stored procedure does extra work. SQL Server checks referenced objects, validates data type compatibility, considers data volume, indexes, operators, joins, unions, grouping, and ordering, then builds an execution plan. Later calls can reuse the cached plan.

Microsoft's query processing documentation also describes SQL Server's plan cache, including object plans for persisted objects like stored procedures.

Recompile is useful when the old cached plan is no longer good because data, indexes, schema, or parameter patterns changed.

Three common recompilation options:

```sql
-- Definition-level
CREATE OR ALTER PROC dbo.usp_sp_demo
WITH RECOMPILE
AS
BEGIN
    SELECT * FROM dbo.SP_ACCOUNT_MASTER;
END;
GO

-- Call-level
EXEC dbo.usp_sp_demo WITH RECOMPILE;

-- Mark for recompile
EXEC sp_recompile 'dbo.usp_sp_demo';
```

The trainer's performance troubleshooting answer:

1. Try recompile if the procedure suddenly became slow.
2. If still slow, open the procedure using `sp_helptext`.
3. Execute queries inside the procedure one by one.
4. Identify the slow query.
5. Check indexes, data volume, and query logic.
6. If the issue is server CPU/RAM/disk/network, involve DBA/infrastructure teams.

## WITH ENCRYPTION

`WITH ENCRYPTION` obfuscates the stored procedure text. The trainer’s warning is very practical: keep a source-code copy before encrypting. If the procedure is encrypted, you cannot easily view/modify the original text from SSMS or `sp_helptext`.

```sql
CREATE PROC dbo.usp_sp_encrypted_demo
WITH ENCRYPTION
AS
BEGIN
    SELECT 'hidden source demo' AS Message;
END;
GO
```

Use this carefully. Do not encrypt practice procedures casually.

## Nesting and Recursion

A stored procedure can call another stored procedure. A procedure can also call itself directly or indirectly. The trainer says stored procedure nesting is allowed up to 32 levels. `@@NESTLEVEL` shows the current nesting depth.

Safe demonstration idea:

```sql
CREATE OR ALTER PROC dbo.usp_sp_nest_demo
AS
BEGIN
    PRINT '@@NESTLEVEL = ' + CAST(@@NESTLEVEL AS VARCHAR(10));
END;
GO
```

If you practice recursion, always add a stopping condition. Never create infinite recursion.

## Debugging Stored Procedures

Debugging means troubleshooting line by line. The trainer compares it to watching a slow-motion replay. In SSMS, the lesson flow is:

1. Write the `EXEC proc_name ...` call.
2. Use debug execution, shown by the trainer as `Alt + F5`.
3. Use `F11` to step through.
4. Watch which line runs.
5. Watch variable and parameter values.
6. Identify where logic goes wrong.

Even if your SSMS version does not support the same debugging experience, the concept remains important: isolate the failing line, inspect variables, test branches, and verify the data after each step.

## Error Handling: @@ERROR and TRY/CATCH

The older style uses `@@ERROR` immediately after a statement. Microsoft Learn notes that `@@ERROR` is reset after each statement, so it must be checked immediately or saved.

```sql
UPDATE dbo.SP_ACCOUNT_MASTER
SET CBAL = CBAL - 1000
WHERE ACID = 101;

IF @@ERROR <> 0
    PRINT 'Error occurred';
```

Modern T-SQL error handling uses `TRY...CATCH`.

```sql
BEGIN TRY
    SELECT 10 / 0;
END TRY
BEGIN CATCH
    SELECT ERROR_LINE() AS ErrorLine,
           ERROR_MESSAGE() AS ErrorMessage,
           ERROR_NUMBER() AS ErrorNumber,
           ERROR_PROCEDURE() AS ErrorProcedure,
           ERROR_SEVERITY() AS ErrorSeverity,
           ERROR_STATE() AS ErrorState;
END CATCH;
```

Error functions to revise:

- `ERROR_LINE()` returns the line where the error occurred
- `ERROR_MESSAGE()` returns message text
- `ERROR_NUMBER()` returns error number
- `ERROR_PROCEDURE()` returns procedure/trigger name
- `ERROR_SEVERITY()` returns severity
- `ERROR_STATE()` returns state

The common real-world pattern is to insert these values into a log table.

```sql
BEGIN CATCH
    INSERT INTO dbo.SP_SQL_LOGS
    (
        ERROR_LINE,
        ERROR_MESSAGE,
        ERROR_NUMBER,
        ERROR_PROCEDURE,
        ERROR_DATE_TIME,
        ERROR_SEVERITY,
        ERROR_STATE
    )
    SELECT ERROR_LINE(),
           ERROR_MESSAGE(),
           ERROR_NUMBER(),
           ERROR_PROCEDURE(),
           GETDATE(),
           ERROR_SEVERITY(),
           ERROR_STATE();

    RETURN 1;
END CATCH;
```

## Types of Stored Procedures

The transcript explains four types at a beginner/interview level.

User-defined stored procedures are the normal procedures developers create, like `dbo.usp_sp_get_customer_balance`.

System stored procedures are built-in procedures, usually in `master`, often starting with `sp_`. Examples include:

```sql
EXEC sp_help 'dbo.SP_ACCOUNT_MASTER';
EXEC sp_helptext 'dbo.usp_sp_get_customer_balance';
EXEC sp_helpdb;
```

Extended stored procedures often start with `xp_` and can interact with things outside normal SQL Server data, such as OS-level information. Examples discussed include `xp_msver`, `xp_fixeddrives`, and `xp_cmdshell`. These are security-sensitive; do not run them casually.

CLR stored procedures use .NET code through SQL Server CLR integration. SQL developers usually create normal T-SQL stored procedures; CLR procedures are for special cases and often require .NET/assembly knowledge.

## Final Interview Rules

Stored procedure can accept inputs and return outputs. Output parameters need `OUTPUT` in definition and call. Return code is integer status, not business data. `IF EXISTS` belongs before the dependent action. Variables are internal; parameters communicate with caller. `PRINT` needs strings, so convert numbers and dates. Stored procedures support deferred name resolution. Views/functions cannot call stored procedures. Stored procedures can call views, functions, and other stored procedures. First execution creates a plan; later executions can reuse it. Recompile is one solution for suddenly slow procedures, but not the only solution. `TRY/CATCH` is preferred over repeated `@@ERROR` checks for modern error handling. Always log useful error details. Do not encrypt a procedure without saving the original source.

