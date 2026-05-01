# SQL Server UDFs - Combined Revision Notebook

Based on:
- `21_transcript.txt`
- `22_transcript.txt`

Run `udf_combined_setup.sql` first. The examples use `company`, `dbo.UDF_ACCOUNT_MASTER`, `dbo.UDF_TXN_MASTER`, `dbo.UDF_EMPLOYEE_PAY`, and `dbo.UDF_MOVIE_CUSTOMER`.

## Quick Revision

UDF means user-defined function. A function is a reusable database program that accepts input parameters, performs a calculation or reads data, and returns a value. The return value can be a single value or a table.

The biggest reason for using a function instead of a stored procedure is call location. A stored procedure is called with `EXEC`, so it cannot be used directly inside a `SELECT`, `WHERE`, `INSERT VALUES`, or join like a table expression. A function can be called inside SQL statements.

```sql
SELECT dbo.udf_get_customer_balance_lesson(101) AS CUSTOMER_BALANCE;
```

Use a UDF when you want to return a value or table without changing database state. Use a stored procedure when you need to insert, update, delete, manage transactions, call many steps, return multiple result sets, or perform action-style work.

UDF types:

- Scalar function: returns one value.
- Inline table-valued function: returns a table using one `SELECT`; this is like a parameterized view.
- Multi-statement table-valued function: returns a table variable after multiple statements.

Important syntax placement:

```sql
DROP FUNCTION IF EXISTS dbo.function_name;
GO

CREATE FUNCTION dbo.function_name (@Input INT)
RETURNS INT
AS
BEGIN
    RETURN @Input * @Input;
END;
GO
```

Always schema-qualify function calls, such as `dbo.udf_name(...)`. In SQL Server, scalar UDF calls commonly fail with "not a recognized built-in function name" when you forget `dbo.`.

## Why Functions Exist

The transcript starts by comparing views, stored procedures, and functions.

A view is a saved query. It is good for centralizing one `SELECT`, but it has no input parameters and no full programming logic.

A stored procedure is powerful. It can have multiple queries, input parameters, output parameters, transactions, `INSERT`, `UPDATE`, `DELETE`, and complex procedural code. Its limitation is that it is called with `EXEC`, not inside normal query expressions.

A UDF fills the gap. It allows reusable logic with parameters and can be used in SQL statements. This is why the trainer says functions are like parameterized views, especially inline table-valued functions.

## UDF Rules And Limitations

Functions are for returning values, not for performing action-style table changes. Inside a SQL Server UDF, you cannot modify database state. That means no normal `INSERT`, `UPDATE`, or `DELETE` against base tables inside the function body.

You also cannot use temporary tables inside a UDF. Use a table variable when you need temporary tabular storage inside a multi-statement table-valued function.

Important practical restrictions:

- UDFs do not have output parameters like stored procedures.
- UDFs use `RETURN` to send back the result.
- A UDF cannot return multiple result sets.
- A UDF cannot call a stored procedure.
- A UDF can call another UDF.
- UDFs cannot use dynamic SQL.
- UDFs do not support `TRY...CATCH`.
- Table variables are allowed; temp tables are not.

You can call a function inside an `INSERT`, `UPDATE`, or `DELETE` statement, but that does not mean the function itself performs the data modification. The outer statement modifies data; the function only supplies a value or table result.

## Scalar Functions

A scalar function returns a single value. Good examples are: get one customer's balance, calculate net salary, generate one next seat number, or return a formatted label.

```sql
CREATE FUNCTION dbo.udf_get_customer_balance_lesson
(
    @AccountID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @Balance MONEY;

    SELECT @Balance = ISNULL(CBAL, 0)
    FROM dbo.UDF_ACCOUNT_MASTER
    WHERE ACID = @AccountID;

    RETURN ISNULL(@Balance, 0);
END;
GO
```

Call it like this:

```sql
SELECT dbo.udf_get_customer_balance_lesson(101) AS CUSTOMER_BALANCE;
```

The function takes an account id as input and returns one balance. If the table has `NULL`, `ISNULL` changes it to `0`. This is important because calculations and display logic often need special treatment for `NULL`.

## Calling Scalar Functions In SQL Statements

A scalar function can be used in the `SELECT` list:

```sql
SELECT
    ACID,
    CUST_NAME,
    dbo.udf_get_customer_balance_lesson(ACID) AS CURRENT_BALANCE
FROM dbo.UDF_ACCOUNT_MASTER;
```

It can be used in a `WHERE` condition:

```sql
SELECT ACID, CUST_NAME, CBAL
FROM dbo.UDF_ACCOUNT_MASTER
WHERE dbo.udf_get_customer_balance_lesson(ACID) >= 10000;
```

It can provide a value during insert:

```sql
INSERT INTO dbo.UDF_ACCOUNT_MASTER
    (ACID, CUST_NAME, BRID, CITY, CBAL, STATUS)
VALUES
    (201, 'Manisha', 'BR1', 'Hyderabad', dbo.udf_get_customer_balance_lesson(101), 'A');
```

It can be used in an update condition:

```sql
UPDATE dbo.UDF_ACCOUNT_MASTER
SET STATUS = 'I'
WHERE CBAL = dbo.udf_get_customer_balance_lesson(104);
```

Again, the outer `INSERT` or `UPDATE` changes the table. The function only returns a value.

## Salary Calculation Function

Functions are useful when you need repeated calculations.

```sql
CREATE FUNCTION dbo.udf_calculate_net_salary_lesson
(
    @BasicPay MONEY,
    @Allowance MONEY,
    @PfAmount MONEY,
    @TaxAmount MONEY
)
RETURNS MONEY
AS
BEGIN
    RETURN (@BasicPay + @Allowance) - (@PfAmount + @TaxAmount);
END;
GO
```

Use it against employee rows:

```sql
SELECT
    EMP_ID,
    EMP_NAME,
    BASIC_PAY,
    ALLOWANCE,
    PF_AMOUNT,
    TAX_AMOUNT,
    dbo.udf_calculate_net_salary_lesson(BASIC_PAY, ALLOWANCE, PF_AMOUNT, TAX_AMOUNT) AS NET_SALARY
FROM dbo.UDF_EMPLOYEE_PAY;
```

This is the kind of "read data, calculate, return result" work where a function is natural.

## Inline Table-Valued Functions

An inline table-valued function returns a table using a single `SELECT`. It has no `BEGIN...END` function body and no table variable. It is very close to a view, but it accepts parameters.

```sql
CREATE FUNCTION dbo.udf_get_accounts_by_branch_lesson
(
    @BranchID CHAR(3)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ACID, CUST_NAME, BRID, CITY, CBAL, STATUS
    FROM dbo.UDF_ACCOUNT_MASTER
    WHERE BRID = @BranchID
);
GO
```

Call it in the `FROM` clause because it returns a table:

```sql
SELECT *
FROM dbo.udf_get_accounts_by_branch_lesson('BR1');
```

This is why inline functions are called parameterized views in the lesson. A view would need separate objects for BR1, BR2, and BR3. The inline function accepts the branch as input.

## Joining Functions With Tables

Table-valued functions return rows and columns, so you can join them with tables.

```sql
SELECT
    a.ACID,
    a.CUST_NAME,
    a.BRID,
    t.TXN_ID,
    t.TXN_TYPE,
    t.TXN_AMOUNT
FROM dbo.udf_get_accounts_by_branch_lesson('BR1') AS a
JOIN dbo.UDF_TXN_MASTER AS t
    ON a.ACID = t.ACID;
```

The function returns BR1 account rows first, then the join finds their transactions. This answers the interview question: yes, a table-valued function can be joined with tables or views when the returned table has a useful common column.

## Multi-Statement Table-Valued Functions

A multi-statement table-valued function returns a table variable. It allows multiple statements before returning the table.

```sql
CREATE FUNCTION dbo.udf_get_account_snapshot_lesson
(
    @AccountID INT
)
RETURNS @Result TABLE
(
    ACID INT,
    CUST_NAME VARCHAR(50),
    BRID CHAR(3),
    CBAL MONEY,
    TXN_COUNT INT
)
AS
BEGIN
    INSERT INTO @Result
        (ACID, CUST_NAME, BRID, CBAL, TXN_COUNT)
    SELECT
        a.ACID,
        a.CUST_NAME,
        a.BRID,
        ISNULL(a.CBAL, 0),
        COUNT(t.TXN_ID)
    FROM dbo.UDF_ACCOUNT_MASTER AS a
    LEFT JOIN dbo.UDF_TXN_MASTER AS t
        ON a.ACID = t.ACID
    WHERE a.ACID = @AccountID
    GROUP BY a.ACID, a.CUST_NAME, a.BRID, a.CBAL;

    RETURN;
END;
GO
```

Here `@Result` is a table variable. Inserting into this return table variable is allowed because it is the function's internal return object. Inserting into a real base table inside the UDF is not allowed.

Call it like this:

```sql
SELECT *
FROM dbo.udf_get_account_snapshot_lesson(101);
```

## Table Variables Vs Temp Tables

A table variable is declared with `DECLARE @X TABLE (...)`. It exists only during the batch/function/procedure execution.

```sql
DECLARE @X TABLE
(
    ID INT,
    NAME VARCHAR(40)
);

INSERT INTO @X VALUES (1, 'AA'), (2, 'BB');
SELECT * FROM @X;
```

A temporary table is created with `CREATE TABLE #Temp (...)`. It lives in `tempdb` and usually lasts until the session ends or it is dropped.

In UDFs, temp tables are not allowed. Table variables are allowed. This is why multi-statement table-valued functions return a table variable.

Beginner rule:

- Small, one-time temporary table-shaped data inside a function: table variable.
- Larger temporary processing across multiple statements outside a function: temp table may be better.

## Seat Number Generation Example

The transcript's best real-world example is automatic seat number generation. A stored procedure can do many things, but you cannot call `EXEC procedure_name` inside an `INSERT VALUES` expression. A scalar function can return the next seat number and can be called during insert.

```sql
CREATE FUNCTION dbo.udf_get_next_seat_lesson()
RETURNS VARCHAR(3)
AS
BEGIN
    DECLARE @LastSeat VARCHAR(3);
    DECLARE @LastRow CHAR(1);
    DECLARE @LastNumber INT;
    DECLARE @NextSeat VARCHAR(3);

    SELECT TOP (1) @LastSeat = SEAT_NO
    FROM dbo.UDF_MOVIE_CUSTOMER
    ORDER BY CUSTOMER_ID DESC;

    IF @LastSeat IS NULL
        SET @NextSeat = 'A1';
    ELSE
    BEGIN
        SET @LastRow = LEFT(@LastSeat, 1);
        SET @LastNumber = CAST(SUBSTRING(@LastSeat, 2, 2) AS INT);

        IF @LastNumber < 12
            SET @NextSeat = @LastRow + CAST(@LastNumber + 1 AS VARCHAR(2));
        ELSE
            SET @NextSeat = CHAR(ASCII(@LastRow) + 1) + '1';
    END;

    RETURN @NextSeat;
END;
GO
```

Use it inside a procedure that performs the actual insert:

```sql
CREATE PROCEDURE dbo.usp_udf_insert_movie_customer_lesson
    @CustomerName VARCHAR(50),
    @Email VARCHAR(80),
    @PhoneNo VARCHAR(20)
AS
BEGIN
    INSERT INTO dbo.UDF_MOVIE_CUSTOMER
        (SEAT_NO, CUSTOMER_NAME, EMAIL, PHONE_NO)
    VALUES
        (dbo.udf_get_next_seat_lesson(), @CustomerName, @Email, @PhoneNo);
END;
GO
```

The function calculates and returns the seat number. The procedure inserts the row. This separation is the important lesson.

## Finding Functions In Metadata

There is `sys.views` for views and `sys.procedures` for procedures, but there is no `sys.functions` table in the same simple way. Use `sys.objects` with object type filters.

```sql
SELECT name, type, type_desc
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
ORDER BY name;
```

Common function object types:

- `FN`: SQL scalar function.
- `IF`: SQL inline table-valued function.
- `TF`: SQL multi-statement table-valued function.

Read a function definition:

```sql
EXEC sp_helptext 'dbo.udf_get_customer_balance_lesson';
```

Alter a function with `ALTER FUNCTION` or `CREATE OR ALTER FUNCTION`.

## UDF Vs Stored Procedure Vs View

View:

- One saved query.
- No input parameters.
- Good for reusable filtered/combined result sets.
- Called in `SELECT`.

Stored procedure:

- Can contain many SQL and T-SQL statements.
- Can insert, update, delete, use transactions, and perform action-style logic.
- Supports input and output parameters.
- Called with `EXEC`.
- Not used directly in `SELECT * FROM proc_name`.

Function:

- Returns one value or a table.
- Supports input parameters.
- No output parameters; uses `RETURN`.
- Can be called inside SQL statements.
- Cannot change database state inside the function.
- Good for calculations, reusable scalar values, parameterized result sets, and table expressions.

## Final Interview Answers

Why do we need UDFs if stored procedures are powerful? Because functions can be used inside SQL statements such as `SELECT` and `WHERE`, while stored procedures are called with `EXEC`.

Can a function insert data into a base table? No. A UDF cannot modify database state. It can be called by an outer `INSERT`, but the function itself only returns a value.

Can a function have output parameters? No. Use `RETURN`.

Can a function use a temp table? No. Use a table variable.

Can a function call a stored procedure? No.

Can a stored procedure call a function? Yes.

What is a scalar function? A function that returns one value.

What is an inline table-valued function? A single-query table-valued function, often described as a parameterized view.

What is a multi-statement table-valued function? A function that uses multiple statements and returns a table variable.

