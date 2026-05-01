# T-SQL Programming - Combined Revision Notebook

Based on:
- `06 SQL Server - T-SQL Programming - Create Varibles.txt`
- `07 SQL Server - T-SQL Programming and Intro to Stored Procedures.txt`

Run `tsql_programming_setup.sql` first. The examples use `company`, `dbo.TSQL_ACCOUNT_MASTER`, and `dbo.TSQL_PRODUCT_MASTER`.

## Quick Revision

SQL is the language used for database commands like `CREATE`, `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `COMMIT`, and permissions. T-SQL means Transact-SQL, Microsoft's SQL Server programming language. T-SQL adds programming features on top of SQL, such as variables, `IF ELSE`, loops, `PRINT`, error handling, stored procedures, functions, and triggers.

Tables centralize data. Views, stored procedures, and functions centralize code. A view is mainly a saved query and does not support full programming logic. Stored procedures and functions can contain T-SQL programming, so they are used when the logic needs variables, parameters, multiple statements, or decision-making.

Use `DECLARE` when you want to create a local variable. Use `SET` or `SELECT` to assign a value. Use `PRINT` to display a simple message in the Messages tab. Use `SELECT` to display output in a result grid.

```sql
DECLARE @X INT;
DECLARE @Y INT;
DECLARE @Z INT;

SET @X = 10;
SET @Y = 20;
SET @Z = @X + @Y;

PRINT @Z;
SELECT @Z AS TOTAL_VALUE;
```

Variables live only during the batch, procedure, or block where they are declared. If you run only `SET @X = 10` later without the `DECLARE`, SQL Server will not remember the earlier variable. `DECLARE` creates memory for the variable in RAM; `CREATE TABLE` or `CREATE PROCEDURE` creates a database object stored in the database.

For object creation, remember batch placement:

```sql
DROP PROCEDURE IF EXISTS dbo.usp_example;
GO

CREATE PROCEDURE dbo.usp_example
AS
BEGIN
    PRINT 'Hello';
END;
GO

EXEC dbo.usp_example;
```

## Why We Learn T-SQL

The trainer's main point is that SQL alone is not enough for complex programming. SQL can create tables, read data, modify data, and manage transactions. But if you need to store temporary values, make decisions, repeat logic, handle errors, or create reusable server-side programs, you need T-SQL.

In SQL Server, stored procedures, user-defined functions, and triggers depend on T-SQL programming. Views normally do not need programming because a view is only a saved `SELECT` query. This is why the lessons move from views into T-SQL before going deeper into stored procedures.

The real project idea is also important: client applications like websites, ATM screens, mobile apps, or desktop applications should not carry all database logic directly. They normally call a view, stored procedure, or function. That hides table details, improves reuse, and allows security to be applied on database objects.

## Variables

A variable is a named memory space used to hold one value temporarily. In SQL Server local variables start with one `@`.

```sql
DECLARE @Salary INT;
SET @Salary = 2000;
PRINT @Salary;
```

Read this as: `@Salary` is a variable capable of storing an integer. Do not say "`@Salary` is an integer." The variable is the container; `INT` is the type of value it can hold.

A variable stores one value at a time. If you assign another value, the old value is replaced.

```sql
DECLARE @X INT;

SET @X = 10;
PRINT @X;

SET @X = 20;
PRINT @X;
```

This prints `10` first, then `20`. It does not mean `@X` stored both values together. The second assignment replaced the first value.

## Data Types For Variables

The variable data type should match the kind of value you want to store.

Common types:

- `INT` stores whole numbers.
- `BIGINT` stores larger whole numbers.
- `TINYINT` stores small non-negative whole numbers.
- `DECIMAL(p, s)` stores exact decimal numbers.
- `MONEY` stores currency-style values.
- `VARCHAR(n)` stores non-Unicode text.
- `NVARCHAR(n)` stores Unicode text.
- `CHAR(n)` stores fixed-length text.
- `DATE` stores only date.
- `DATETIME` stores date and time.
- `BIT` stores 0, 1, or `NULL`.

Examples:

```sql
DECLARE @EmployeeID INT;
DECLARE @Name VARCHAR(100);
DECLARE @Salary MONEY;
DECLARE @JoinDate DATE;
DECLARE @IsActive BIT;
```

The lesson compares table columns and variables. If a table has `EmployeeID`, `Name`, and `Salary`, a program can read one row into three variables, process it, then move to the next row. Tables can store many rows permanently; variables hold temporary values for processing.

## DECLARE, SET, SELECT, And PRINT

`DECLARE` creates the variable.

```sql
DECLARE @X INT;
```

`SET` assigns one value.

```sql
SET @X = 10;
```

`SELECT` can display a variable in the Results grid.

```sql
SELECT @X AS X_VALUE;
```

`PRINT` displays a message in the Messages tab.

```sql
PRINT @X;
```

When you concatenate text with a number, convert the number to text first.

```sql
DECLARE @X INT = 45;
DECLARE @Y INT = 50;
DECLARE @Z INT;

SET @Z = @X + @Y;

PRINT 'Total value is ' + CAST(@Z AS VARCHAR(20));
SELECT 'Total value is ' + CAST(@Z AS VARCHAR(20)) AS MESSAGE_TEXT;
```

`PRINT @Z AS TOTAL_VALUE` is not valid. Aliases like `AS TOTAL_VALUE` belong with `SELECT`, not `PRINT`.

## Local Variables And Global Variables

Local variables are user-defined variables. They start with one `@`, such as `@X`, `@Salary`, or `@AccountID`. They exist only for the current batch, procedure, or function execution.

Global variables in SQL Server are system-defined values that start with `@@`. You do not create them with `DECLARE`. SQL Server provides them.

Useful examples:

```sql
SELECT @@VERSION AS SQL_SERVER_VERSION;
SELECT @@SERVERNAME AS SERVER_NAME;
SELECT @@ROWCOUNT AS LAST_STATEMENT_ROWCOUNT;
```

At this lesson level, remember the difference: `@VariableName` is created by you, and `@@SystemValue` is provided by SQL Server.

## Execution Scope And Lifetime

Variables are temporary. They are not stored in the database table, and they do not remain forever. After the batch finishes, the local variable is gone.

This works because all statements are executed together:

```sql
DECLARE @X INT;
SET @X = 10;
PRINT @X;
```

This does not work if you run only the second line separately later:

```sql
SET @X = 10;
```

SQL Server will say the variable must be declared because the earlier execution already ended. This is why the trainer says you cannot execute variable programs one line at a time unless the variable declaration is included in the same execution.

## PRINT Vs SELECT

`PRINT` is for simple messages. It appears in the Messages tab.

```sql
PRINT 'Program started';
```

`SELECT` returns a result set. It appears in the Results tab and can be consumed by applications.

```sql
SELECT ACID, CUST_NAME, CBAL
FROM dbo.TSQL_ACCOUNT_MASTER;
```

For debugging small T-SQL programs, `PRINT` is useful. For returning data to a user, report, app, or query window, `SELECT` is usually the better output.

## Intro To Stored Procedures

A stored procedure is a saved program in the database. It can contain SQL plus T-SQL. The lesson introduces procedures because variable programs disappear when the query window closes unless we store the code somewhere. A procedure stores the code in the database, and when we execute it, SQL Server runs that code.

Basic syntax:

```sql
CREATE PROCEDURE dbo.usp_tsql_add_numbers_lesson
AS
BEGIN
    DECLARE @X INT;
    DECLARE @Y INT;
    DECLARE @Z INT;

    SET @X = 10;
    SET @Y = 20;
    SET @Z = @X + @Y;

    PRINT @Z;
END;
GO

EXEC dbo.usp_tsql_add_numbers_lesson;
```

Inside a stored procedure, you can use SQL commands and T-SQL programming. The transcript mentions that procedures can contain DDL, DML, variables, temp tables, calls to views, calls to functions, and even calls to other procedures. In real projects, use that power carefully and keep procedures focused.

## Calling A Procedure Vs Calling A View Or Function

A view is used in `SELECT`:

```sql
SELECT *
FROM dbo.SomeView;
```

A function can often be used in `SELECT`:

```sql
SELECT GETDATE() AS CURRENT_DATE_TIME;
```

A stored procedure is executed with `EXEC` or `EXECUTE`:

```sql
EXEC dbo.usp_tsql_add_numbers_lesson;
```

This is a major interview point from the lesson. You do not call a stored procedure like a table in `SELECT * FROM procedure_name`.

## Input Parameters

If values are hard-coded inside a procedure, the procedure always does the same thing. The lesson first shows an add-numbers procedure where `10` and `20` are written inside the code. That is not flexible.

Input parameters solve this. A parameter is declared in the procedure header and receives a value from the caller.

```sql
CREATE OR ALTER PROCEDURE dbo.usp_tsql_add_numbers_lesson
    @X INT,
    @Y INT
AS
BEGIN
    DECLARE @Z INT;

    SET @Z = @X + @Y;

    PRINT 'Total value is ' + CAST(@Z AS VARCHAR(20));
    SELECT @Z AS TOTAL_VALUE;
END;
GO

EXEC dbo.usp_tsql_add_numbers_lesson 10, 20;
EXEC dbo.usp_tsql_add_numbers_lesson 50, 400;
```

The caller supplies `@X` and `@Y`. This is like an ATM screen asking how much cash you want to withdraw, or a shopping website asking which category you selected.

## Account Balance Procedure Example

A view cannot accept an account id parameter. A stored procedure can.

```sql
CREATE OR ALTER PROCEDURE dbo.usp_tsql_get_account_balance_lesson
    @AccountID INT
AS
BEGIN
    SELECT ACID, CUST_NAME, CBAL
    FROM dbo.TSQL_ACCOUNT_MASTER
    WHERE ACID = @AccountID;
END;
GO

EXEC dbo.usp_tsql_get_account_balance_lesson 101;
EXEC dbo.usp_tsql_get_account_balance_lesson 102;
```

If the account id exists, the procedure returns the account balance. If the account id does not exist, this beginner version returns no row. Later lessons improve this with validation and messages.

## Product Category Procedure Example

The transcript explains front-end category selections using examples like books, electronics, or products. The category selected by the user becomes an input parameter.

```sql
CREATE OR ALTER PROCEDURE dbo.usp_tsql_get_products_by_category_lesson
    @Category VARCHAR(30)
AS
BEGIN
    SELECT PRODUCT_ID, PRODUCT_NAME, CATEGORY, PRICE, STOCK_QTY
    FROM dbo.TSQL_PRODUCT_MASTER
    WHERE CATEGORY = @Category;
END;
GO

EXEC dbo.usp_tsql_get_products_by_category_lesson 'Books';
EXEC dbo.usp_tsql_get_products_by_category_lesson 'Electronics';
```

The application only needs to call the procedure and pass the selected category. The table name and filter logic stay inside SQL Server.

## Important Interview Points

T-SQL is SQL Server's programming language. It is used to build stored procedures, functions, triggers, and more complex scripts.

`DECLARE` creates a local variable in memory. `CREATE` creates a database object such as a table, view, or procedure.

A variable stores one value at a time. A table stores many rows permanently.

`PRINT` writes to Messages. `SELECT` returns a result set.

Local variables start with `@`. SQL Server system variables/functions commonly start with `@@`.

Views do not accept input parameters. Stored procedures can accept input parameters.

Stored procedures are called using `EXEC`, not as `SELECT * FROM proc_name`.

Input parameters allow the same procedure to work for different user inputs, such as account id, product category, city, date range, or amount.

