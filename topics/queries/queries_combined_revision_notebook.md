# SQL Query Revision Notebook

Run `queries_combined_setup.sql` first. The examples here stay close to the lesson style: banking tables like account master and transaction master, employee salary questions, month-wise new customers, item/color cube examples, ranking functions, derived tables, and CTEs. I also added missing but required SQL Server query topics such as joins, `GROUP BY`, `HAVING`, and date functions at the same lesson level.

Official SQL Server references used for added/missing topics: Microsoft Learn for `GROUP BY`, `HAVING`, aggregate functions, date/time functions, `FROM`/`JOIN`, and `SELECT` logical processing order.

## Quick Revision

The most important query order to remember is:

```sql
SELECT column_list
FROM table_name
JOIN other_table ON join_condition
WHERE row_filter
GROUP BY grouping_columns
HAVING group_filter
ORDER BY sort_columns;
```

The written order starts with `SELECT`, but the logical processing order is different. SQL Server logically starts from `FROM`, then `ON`, `JOIN`, `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `DISTINCT`, `ORDER BY`, and finally `TOP`. This is why a column alias created in `SELECT` cannot normally be used in `WHERE`, but it can be used in `ORDER BY`.

Use `WHERE` when you want to filter normal rows before grouping. Use `GROUP BY` when you want one result row per branch, product, status, month, department, or any group. Use `HAVING` when you want to filter after aggregation, such as branches where `COUNT(*) > 5` or products where `SUM(CBAL) > 100000`. A simple interview rule is: `WHERE` filters rows, `HAVING` filters groups.

When you use aggregate functions with other selected columns, every non-aggregate selected column must be in `GROUP BY`. This is why `SELECT BRID, COUNT(*) FROM Q_ACCOUNT_MASTER GROUP BY BRID` works, but `SELECT BRID, NAME, COUNT(*) FROM Q_ACCOUNT_MASTER GROUP BY BRID` does not work unless `NAME` is also grouped or handled separately.

Use `IF EXISTS` before the action when you want to check whether something exists. For example, before dropping a table, check `IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employee') DROP TABLE Employee;`. The `EXISTS` condition becomes true when the subquery returns at least one row. Use `IF NOT EXISTS` when you want to create something only if it is missing.

Use `=` when a subquery returns one value. Use `IN` when a subquery returns multiple values from one column. SQL Server subqueries in this lesson style should return a single column when used with `IN`. If your subquery can return many rows and you use `=`, SQL Server will throw the classic "subquery returned more than one value" error.

Use joins when you need to display columns from more than one table. Use subqueries or correlated subqueries when the second table is mainly used for checking/filtering and you do not need to display its columns. Use derived tables when you want to prepare/filter/group data first, then join it later. The trainer’s performance rule is worth remembering: filter data as early as possible and join as late as possible.

## SELECT, FROM, WHERE, ORDER BY

The trainer starts query lessons by separating storing data from retrieving data. Tables, keys, and inserts help store data, but most real work happens while retrieving data. In the lesson, the main table is an account master table. In this notebook, use `Q_ACCOUNT_MASTER`.

To get all columns and all rows, use `SELECT *`.

```sql
SELECT *
FROM dbo.Q_ACCOUNT_MASTER;
```

To get only some columns but all rows, list the column names in `SELECT`.

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER;
```

To get all columns but only some rows, keep `*` and add `WHERE`.

```sql
SELECT *
FROM dbo.Q_ACCOUNT_MASTER
WHERE BRID = 'BR1';
```

To filter both columns and rows, list columns and use `WHERE`.

```sql
SELECT ACID, NAME, PID, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE PID = 'SB';
```

String values like `'BR1'`, `'SB'`, and `'Active'` need single quotes. Numeric values like `10000` do not need quotes.

`ORDER BY` sorts the result. If you do not write `ASC` or `DESC`, SQL Server sorts ascending by default.

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE PID = 'SB'
ORDER BY NAME DESC;
```

## Constants, Aliases, and Concatenation

The lesson shows that `SELECT 5` simply prints a constant. It does not mean "fifth column" because there is no table or column reference.

```sql
SELECT 5 AS [My Lucky Number];
SELECT 'Java' AS [Course Name];
```

You can print constants together with table columns. This is useful when a value like currency or tax is not stored in the table but must appear in the report.

```sql
SELECT ACID,
       NAME,
       'USD' AS Currency,
       CBAL,
       '18%' AS TaxRate
FROM dbo.Q_ACCOUNT_MASTER;
```

Use aliases to give readable column names. If the alias has spaces, put it in square brackets.

```sql
SELECT NAME AS [Customer Name],
       CBAL AS [Clear Balance]
FROM dbo.Q_ACCOUNT_MASTER;
```

Use `+` to concatenate strings in the lesson style. If you concatenate a string with a number/date, convert the number/date first.

```sql
SELECT NAME + ' is doing SQL course with Go Online' AS StatusLine
FROM dbo.Q_ACCOUNT_MASTER;

SELECT NAME + ' has balance INR ' + CAST(CBAL AS VARCHAR(30)) AS BalanceLine
FROM dbo.Q_ACCOUNT_MASTER;
```

## CAST and CONVERT

`CAST` and `CONVERT` change one data type into another. The trainer’s example is converting `CBAL` from money to varchar so it can be concatenated with text.

```sql
SELECT NAME + ' has balance INR ' + CAST(CBAL AS VARCHAR(30)) AS BalanceLine
FROM dbo.Q_ACCOUNT_MASTER;
```

`CONVERT` can do the same type conversion, but it also supports style numbers for dates.

```sql
SELECT NAME + ' has balance INR ' + CONVERT(VARCHAR(30), CBAL) AS BalanceLine
FROM dbo.Q_ACCOUNT_MASTER;
```

For date formatting, `CONVERT` is more useful because of style numbers.

```sql
SELECT ACID,
       NAME,
       DOO,
       CONVERT(VARCHAR(30), DOO, 101) AS US_Date,
       CONVERT(VARCHAR(30), DOO, 103) AS India_Date,
       CONVERT(VARCHAR(30), DOO, 107) AS Month_Name_Date
FROM dbo.Q_ACCOUNT_MASTER;
```

Interview note: `CAST` is ANSI-standard and portable. `CONVERT` is SQL Server-specific and preferred when SQL Server date style formatting is needed.

## NULL Functions

The transcript discusses `ISNULL`, `COALESCE`, and `NULLIF`.

`ISNULL(expression, replacement)` replaces `NULL` with a value.

```sql
SELECT TXN_ID,
       TXN_TYPE,
       ISNULL(CAST(CHQ_NO AS VARCHAR(20)), 'No cheque') AS ChequeInfo
FROM dbo.Q_TXN_MASTER;
```

`COALESCE(value1, value2, value3...)` returns the first non-null value. It is useful when multiple fallback columns/values are possible.

```sql
SELECT COALESCE(NULL, NULL, 'SQL Server') AS FirstAvailableValue;
```

`NULLIF(value1, value2)` returns `NULL` when both values are equal; otherwise it returns the first value.

```sql
SELECT ACID,
       NAME,
       CBAL,
       UBAL,
       NULLIF(CBAL, UBAL) AS BalanceDifferenceFlag
FROM dbo.Q_ACCOUNT_MASTER;
```

The lesson rule is simple: `ISNULL` replaces an existing null, while `NULLIF` creates a null when two expressions match.

## Aggregate Functions

Aggregate functions calculate one answer from many rows. Microsoft Learn notes that aggregate functions return a single value from a set of values, and except for `COUNT(*)`, they ignore `NULL` values.

Common aggregate functions for this level:

`COUNT(*)` counts rows. `COUNT(column)` counts non-null values in that column. `SUM()` adds numeric values. `AVG()` calculates average. `MIN()` returns the smallest value. `MAX()` returns the largest value. `COUNT(DISTINCT column)` counts unique non-null values. `STRING_AGG()` combines strings across grouped rows in newer SQL Server versions.

```sql
SELECT COUNT(*) AS TotalAccounts,
       SUM(CBAL) AS TotalClearBalance,
       AVG(CBAL) AS AverageClearBalance,
       MIN(CBAL) AS MinimumBalance,
       MAX(CBAL) AS MaximumBalance
FROM dbo.Q_ACCOUNT_MASTER;
```

You can filter rows before aggregation with `WHERE`.

```sql
SELECT COUNT(*) AS ActiveSavingsAccounts,
       SUM(CBAL) AS TotalBalance
FROM dbo.Q_ACCOUNT_MASTER
WHERE STATUS = 'A'
  AND PID = 'SB';
```

## GROUP BY and HAVING

`GROUP BY` divides rows into groups and returns one row per group. In the lesson style, "branch-wise count", "product-wise balance", "department-wise average salary", and "month-wise customers" all mean grouping.

```sql
SELECT BRID,
       COUNT(*) AS NumberOfAccounts,
       SUM(CBAL) AS TotalBalance
FROM dbo.Q_ACCOUNT_MASTER
GROUP BY BRID;
```

When the selected column is not inside an aggregate function, it must appear in `GROUP BY`.

```sql
SELECT BRID, PID, COUNT(*) AS AccountCount
FROM dbo.Q_ACCOUNT_MASTER
GROUP BY BRID, PID;
```

Use `HAVING` for aggregate filters.

```sql
SELECT BRID,
       COUNT(*) AS NumberOfAccounts
FROM dbo.Q_ACCOUNT_MASTER
GROUP BY BRID
HAVING COUNT(*) > 2;
```

Do not write aggregate filters in `WHERE`.

```sql
-- Wrong:
-- SELECT BRID, COUNT(*) FROM dbo.Q_ACCOUNT_MASTER
-- WHERE COUNT(*) > 2
-- GROUP BY BRID;
```

## Date Functions

Important SQL Server date functions at this lesson level:

`GETDATE()` returns the current SQL Server system date and time. `DATEADD(part, number, date)` adds or subtracts a date part. `DATEDIFF(part, start, end)` returns the boundary difference between two dates. `DATENAME(part, date)` returns a name like month name. `DATEPART(part, date)` returns a number like month number or year number. `DAY()`, `MONTH()`, and `YEAR()` return simple parts. `EOMONTH(date)` returns the last day of a month.

```sql
SELECT GETDATE() AS CurrentDateTime,
       DATEADD(MONTH, -1, GETDATE()) AS OneMonthBack,
       DATENAME(MONTH, GETDATE()) AS CurrentMonthName,
       DATEPART(YEAR, GETDATE()) AS CurrentYearNumber,
       EOMONTH(GETDATE()) AS CurrentMonthEnd;
```

Lesson example: accounts opened between two years.

```sql
SELECT ACID, NAME, DOO
FROM dbo.Q_ACCOUNT_MASTER
WHERE DATEPART(YEAR, DOO) BETWEEN 2019 AND 2021;
```

Interview/practical note: for indexed date columns, exact date ranges are often better than applying functions to the column.

```sql
SELECT *
FROM dbo.Q_TXN_MASTER
WHERE DOT >= '2021-01-01'
  AND DOT <  '2022-01-01';
```

## BETWEEN, IN, LIKE, and CASE

`BETWEEN` includes both lower and upper limits.

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE CBAL BETWEEN 10000 AND 50000;
```

`IN` is a clean shortcut for multiple `OR` checks.

```sql
SELECT ACID, NAME, BRID
FROM dbo.Q_ACCOUNT_MASTER
WHERE BRID IN ('BR1', 'BR3');
```

`LIKE` searches patterns. `%` means any number of characters; `_` means one character.

```sql
SELECT ACID, NAME
FROM dbo.Q_ACCOUNT_MASTER
WHERE NAME LIKE 'B%';
```

`CASE` is SQL query-level conditional logic. It is like `IF/ELSE` for query output.

```sql
SELECT ACID,
       NAME,
       CBAL,
       CASE
           WHEN CBAL < 10000 THEN 'Silver Customer'
           WHEN CBAL BETWEEN 10000 AND 50000 THEN 'Gold Customer'
           ELSE 'Diamond Customer'
       END AS CustomerType
FROM dbo.Q_ACCOUNT_MASTER;
```

Lesson-style gender title example:

```sql
SELECT EMP_ID,
       CASE
           WHEN GENDER = 'M' THEN 'Mr. ' + EMP_NAME
           WHEN GENDER = 'F' THEN 'Ms. ' + EMP_NAME
           ELSE EMP_NAME
       END AS EmployeeNameWithTitle
FROM dbo.Q_EMPLOYEE_INFO;
```

## String Functions

Common string functions to revise together:

`LEN()` returns length. `LEFT()` returns left characters. `RIGHT()` returns right characters. `SUBSTRING()` returns part of a string. `CHARINDEX()` finds a substring position. `PATINDEX()` finds a pattern position. `REPLACE()` replaces text. `UPPER()` and `LOWER()` change case. `LTRIM()`, `RTRIM()`, and `TRIM()` remove spaces. `SPACE(n)` creates spaces. `CONCAT()` safely concatenates values. `STRING_AGG()` aggregates many row values into one string.

```sql
SELECT NAME,
       LEN(NAME) AS NameLength,
       LEFT(NAME, 3) AS FirstThree,
       RIGHT(NAME, 3) AS LastThree,
       UPPER(NAME) AS UpperName,
       LOWER(NAME) AS LowerName
FROM dbo.Q_ACCOUNT_MASTER;
```

```sql
SELECT NAME,
       SUBSTRING(NAME, 1, 5) AS NamePart,
       CHARINDEX(' ', NAME) AS SpacePosition,
       REPLACE(NAME, ' ', '-') AS HyphenName
FROM dbo.Q_ACCOUNT_MASTER;
```

## Joins

Joins are missing from these exact transcripts but are essential at this level. SQL Server supports `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`, and `CROSS JOIN`.

Use a join when you need columns from more than one table. The normal join condition goes in `ON`.

```sql
SELECT A.ACID,
       A.NAME,
       A.BRID,
       B.BRANCH_NAME,
       B.CITY
FROM dbo.Q_ACCOUNT_MASTER AS A
INNER JOIN dbo.Q_BRANCH_MASTER AS B
    ON A.BRID = B.BRID;
```

`INNER JOIN` returns only matching rows. `LEFT JOIN` returns all left-table rows and matching right-table rows; missing right-side values become `NULL`.

```sql
SELECT A.ACID,
       A.NAME,
       T.TXN_ID,
       T.TXN_AMOUNT
FROM dbo.Q_ACCOUNT_MASTER AS A
LEFT JOIN dbo.Q_TXN_MASTER AS T
    ON A.ACID = T.ACID;
```

`CROSS JOIN` returns every combination, so use it carefully.

```sql
SELECT B.BRID, P.PID
FROM dbo.Q_BRANCH_MASTER AS B
CROSS JOIN dbo.Q_PRODUCT_MASTER AS P;
```

Self join means joining a table to itself. It is useful for comparing rows inside the same table.

```sql
SELECT E1.EMP_NAME AS Employee1,
       E2.EMP_NAME AS Employee2,
       E1.DEPT_NAME
FROM dbo.Q_EMPLOYEE_INFO AS E1
JOIN dbo.Q_EMPLOYEE_INFO AS E2
    ON E1.DEPT_NAME = E2.DEPT_NAME
   AND E1.EMP_ID < E2.EMP_ID;
```

## Subqueries

A subquery is a query inside another query. In the lessons, a query inside `WHERE`, `SELECT`, or `HAVING` is called a subquery. The inner query executes first for a normal subquery, then its result is used by the outer query.

Example: who has the highest balance?

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE CBAL = (SELECT MAX(CBAL) FROM dbo.Q_ACCOUNT_MASTER);
```

Example: difference between each account balance and average balance. This needs the subquery in the `SELECT` list because mixing row columns with `AVG(CBAL)` directly would require grouping and would not mean the same thing.

```sql
SELECT ACID,
       NAME,
       CBAL,
       CBAL - (SELECT AVG(CBAL) FROM dbo.Q_ACCOUNT_MASTER) AS DifferenceFromAverage
FROM dbo.Q_ACCOUNT_MASTER;
```

Second highest balance lesson logic: find max, eliminate it, then find max again.

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE CBAL =
(
    SELECT MAX(CBAL)
    FROM dbo.Q_ACCOUNT_MASTER
    WHERE CBAL < (SELECT MAX(CBAL) FROM dbo.Q_ACCOUNT_MASTER)
);
```

Nth highest lesson logic: sort distinct balances, take top N, then find minimum of that set.

```sql
SELECT ACID, NAME, CBAL
FROM dbo.Q_ACCOUNT_MASTER
WHERE CBAL =
(
    SELECT MIN(CBAL)
    FROM dbo.Q_ACCOUNT_MASTER
    WHERE CBAL IN
    (
        SELECT DISTINCT TOP 3 CBAL
        FROM dbo.Q_ACCOUNT_MASTER
        ORDER BY CBAL DESC
    )
);
```

## Correlated Subqueries and EXISTS

A correlated subquery depends on the outer query. The outer query gives a value to the inner query row by row. Use this when the inner query must compare with the current outer row.

Employee salary higher than department average:

```sql
SELECT E.EMP_ID, E.EMP_NAME, E.SALARY, E.DEPT_NAME
FROM dbo.Q_EMPLOYEE_INFO AS E
WHERE E.SALARY >
(
    SELECT AVG(E2.SALARY)
    FROM dbo.Q_EMPLOYEE_INFO AS E2
    WHERE E2.DEPT_NAME = E.DEPT_NAME
);
```

`EXISTS` checks whether at least one matching row exists.

```sql
SELECT A.ACID, A.NAME
FROM dbo.Q_ACCOUNT_MASTER AS A
WHERE EXISTS
(
    SELECT 1
    FROM dbo.Q_TXN_MASTER AS T
    WHERE T.ACID = A.ACID
);
```

System-table lesson example:

```sql
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Q_ACCOUNT_MASTER')
BEGIN
    PRINT 'Table exists';
END;
```

## System Tables

The trainer uses system tables to answer practical metadata questions. `sys.tables` stores table metadata for the current database. `sys.columns` stores column metadata. `sys.databases` stores database metadata.

```sql
SELECT *
FROM sys.tables;

SELECT COUNT(*) AS NumberOfTables
FROM sys.tables;
```

Find number of columns in a table:

```sql
SELECT COUNT(*) AS NumberOfColumns
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.Q_ACCOUNT_MASTER');
```

Generate dynamic-looking text from metadata:

```sql
SELECT 'SELECT * FROM dbo.' + name + ';' AS SelectStatement
FROM sys.tables
WHERE name LIKE 'Q_%';
```

## Derived Tables

A derived table is a query in the `FROM` clause. It must have an alias.

```sql
SELECT *
FROM
(
    SELECT ACID, NAME, CBAL
    FROM dbo.Q_ACCOUNT_MASTER
) AS K;
```

The trainer’s important performance example: instead of joining all transaction rows and filtering later, first filter/group transaction data, then join the smaller prepared result.

```sql
SELECT A.ACID,
       A.NAME,
       K.NumberOfTransactions
FROM dbo.Q_ACCOUNT_MASTER AS A
JOIN
(
    SELECT ACID,
           COUNT(*) AS NumberOfTransactions
    FROM dbo.Q_TXN_MASTER
    WHERE DATEPART(YEAR, DOT) = 2021
    GROUP BY ACID
) AS K
    ON A.ACID = K.ACID;
```

The derived table prepares 2021 transaction counts first. Then the join only adds account names.

Month-wise new customers lesson logic:

```sql
SELECT DATENAME(MONTH, K.FirstSaleDate) AS MonthName,
       COUNT(*) AS NewCustomers
FROM
(
    SELECT CUSTOMER_ID,
           MIN(DOS) AS FirstSaleDate
    FROM dbo.Q_CUSTOMER_SALES
    GROUP BY CUSTOMER_ID
) AS K
GROUP BY DATEPART(MONTH, K.FirstSaleDate),
         DATENAME(MONTH, K.FirstSaleDate)
ORDER BY DATEPART(MONTH, K.FirstSaleDate);
```

## CUBE and ROLLUP

`CUBE` and `ROLLUP` create subtotal/grand-total style aggregations. In the lesson, item and color sales are used to explain data analytics.

Normal item/color aggregation:

```sql
SELECT ITEM_NAME, COLOR, SUM(QTY) AS TotalQty
FROM dbo.Q_ITEM_SALES
GROUP BY ITEM_NAME, COLOR;
```

`CUBE` gives all combinations of totals: item-color, item total, color total, and grand total.

```sql
SELECT ITEM_NAME, COLOR, SUM(QTY) AS TotalQty
FROM dbo.Q_ITEM_SALES
GROUP BY CUBE (ITEM_NAME, COLOR);
```

`ROLLUP` gives hierarchical totals from left to right. With `(ITEM_NAME, COLOR)`, it gives item-color, item total, and grand total, but fewer combinations than cube.

```sql
SELECT ITEM_NAME, COLOR, SUM(QTY) AS TotalQty
FROM dbo.Q_ITEM_SALES
GROUP BY ROLLUP (ITEM_NAME, COLOR);
```

## Ranking Functions

Ranking functions assign numbers to rows. They use `OVER(ORDER BY ...)`. `PARTITION BY` restarts the ranking inside each group.

`ROW_NUMBER()` gives a unique sequence: 1, 2, 3, 4.

```sql
SELECT ROW_NUMBER() OVER (ORDER BY ACID) AS RowNo,
       ACID,
       NAME,
       CBAL
FROM dbo.Q_ACCOUNT_MASTER;
```

To filter on the row number, use a derived table or CTE because the alias is not available in `WHERE`.

```sql
SELECT *
FROM
(
    SELECT ROW_NUMBER() OVER (ORDER BY ACID) AS RowNo,
           ACID,
           NAME,
           CBAL
    FROM dbo.Q_ACCOUNT_MASTER
) AS K
WHERE K.RowNo BETWEEN 5 AND 10;
```

`RANK()` gives the same rank to ties and leaves gaps. `DENSE_RANK()` gives the same rank to ties but does not leave gaps.

```sql
SELECT ACID,
       NAME,
       CBAL,
       RANK() OVER (ORDER BY CBAL DESC) AS BalanceRank,
       DENSE_RANK() OVER (ORDER BY CBAL DESC) AS DenseBalanceRank
FROM dbo.Q_ACCOUNT_MASTER;
```

Use `DENSE_RANK()` when you want first highest, second highest, third highest, etc. without missing a rank number due to duplicate balances.

```sql
SELECT *
FROM
(
    SELECT ACID,
           NAME,
           BRID,
           CBAL,
           DENSE_RANK() OVER (PARTITION BY BRID ORDER BY CBAL DESC) AS BranchBalanceRank
    FROM dbo.Q_ACCOUNT_MASTER
) AS K
WHERE K.BranchBalanceRank = 2;
```

`NTILE(n)` splits sorted rows into `n` groups.

```sql
SELECT ACID,
       NAME,
       NTILE(3) OVER (ORDER BY ACID) AS GroupNumber
FROM dbo.Q_ACCOUNT_MASTER;
```

## CTE

A CTE, or common table expression, is similar to a derived table but is written before the main query using `WITH`. It makes complex queries easier to read.

```sql
WITH AccountRows AS
(
    SELECT ROW_NUMBER() OVER (ORDER BY ACID) AS RowNo,
           ACID,
           NAME,
           CBAL
    FROM dbo.Q_ACCOUNT_MASTER
)
SELECT *
FROM AccountRows
WHERE RowNo = 5;
```

When a CTE is not the first statement in a batch, terminate the previous statement with a semicolon. You will often see `;WITH CTEName AS (...)`.

```sql
;WITH BranchCounts AS
(
    SELECT BRID, COUNT(*) AS CustomerCount
    FROM dbo.Q_ACCOUNT_MASTER
    GROUP BY BRID
),
RankedBranches AS
(
    SELECT BRID,
           CustomerCount,
           DENSE_RANK() OVER (ORDER BY CustomerCount DESC) AS BranchRank
    FROM BranchCounts
)
SELECT *
FROM RankedBranches
WHERE BranchRank = 1;
```

## Final Interview Rules

Keep these in your head before interviews. `SELECT *` is okay for learning but avoid it in production reports when specific columns are enough. Use square brackets for aliases with spaces. Use single quotes for string/date literals. Use `AND`/`OR`, not `&`/`|`, in normal SQL conditions. `BETWEEN` includes both ends. `WHERE` filters rows before grouping. `HAVING` filters groups after grouping. Aggregate functions belong in the `SELECT` list or `HAVING` clause, not normal `WHERE`. Non-aggregate selected columns must be in `GROUP BY`. Derived tables need aliases. Ranking function aliases need a derived table or CTE before filtering. `DENSE_RANK` is better than `RANK` for nth-highest style questions. Use joins when displaying columns from both tables; use subqueries/`EXISTS` when checking another table. Filter early, join late when it helps performance.

