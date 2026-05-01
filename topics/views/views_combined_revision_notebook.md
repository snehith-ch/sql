# SQL Server Views - Combined Revision Notebook

Based on:
- `2_transcript.txt`
- `3_transcript.txt`
- `4_transcript.txt`
- `05 SQL Server - Views Part4 - Schemas and Indexed Views.txt`

Run `views_combined_setup.sql` first. The examples use `company`, `dbo.ACCOUNT_MASTER_VW`, `dbo.BRANCH_MASTER_VW`, `dbo.TRANSACTION_MASTER_VW`, `reporting_lvw`, `dbo.fn_ActiveAccounts_LVW()`, and `dbo.usp_GetActiveAccounts_LVW`.

## Quick Revision

A view is a saved `SELECT` query stored as a database object. You call it like a table:

```sql
SELECT *
FROM dbo.vw_br1_accounts_lvw;
```

A normal view is called a virtual table because it does not keep its own copy of the rows. Whenever you query the view, SQL Server uses the view definition and reads the latest data from the base table. This is useful because your front-end application, report, or portal can call one simple object name instead of carrying a long query everywhere.

Use a view when you want to centralize one reusable query, hide unnecessary columns, show only selected rows, or give users access to a controlled result instead of the whole base table. Use a stored procedure when you need multiple statements, variables, `IF ELSE`, `INSERT`, `UPDATE`, `DELETE`, transaction logic, or parameters.

The normal logical order of a query is:

```sql
SELECT columns
FROM table_or_view
JOIN other_table ON join_condition
WHERE row_filter
GROUP BY grouping_columns
HAVING group_filter
ORDER BY final_sort;
```

`WHERE` filters rows before grouping. `GROUP BY` forms groups. `HAVING` filters after grouping, usually with aggregate conditions like `SUM(AMOUNT) > 10000`. `ORDER BY` should be placed in the outer query when selecting from a view. In SQL Server, `ORDER BY` inside a view definition is only meaningful with options like `TOP` or `OFFSET`, and it still does not guarantee final display order unless the outer query also has `ORDER BY`.

Use `IF EXISTS` or `IF NOT EXISTS` before `CREATE SCHEMA` or older object-drop patterns. For modern SQL Server, use `DROP VIEW IF EXISTS view_name;` before recreating a practice view. `CREATE VIEW` should be in its own batch, so keep `GO` before and after it.

```sql
DROP VIEW IF EXISTS dbo.vw_example_lvw;
GO

CREATE VIEW dbo.vw_example_lvw
AS
SELECT ACID, CUST_NAME
FROM dbo.ACCOUNT_MASTER_VW;
GO
```

## Core Meaning Of A View

In the lessons, the trainer repeatedly says that a view is a single query. That does not mean the query must be small. A view definition can have joins, subqueries, aggregates, filters, and expressions, but it is still one `SELECT` statement stored as a database object.

The main reason for using a view is centralization. If a bank manager needs only BR1 customers, we do not want every report, button, and developer to rewrite the same `WHERE BRID = 'BR1'` query. We create one view and let applications call that view. This also helps with security because permissions can be given on the view instead of exposing the full base table.

```sql
CREATE VIEW dbo.vw_br1_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';
GO

SELECT *
FROM dbo.vw_br1_accounts_lvw;
```

If a new BR1 account is inserted into `dbo.ACCOUNT_MASTER_VW`, the view will show it the next time you query the view. That is the fresh-data behavior of a normal view.

## Create, Call, Alter, Drop, And Inspect Views

Create a view with `CREATE VIEW`, read from it with `SELECT`, modify its definition with `ALTER VIEW`, and remove it with `DROP VIEW`.

```sql
ALTER VIEW dbo.vw_br1_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';
GO

EXEC sp_helptext 'dbo.vw_br1_accounts_lvw';

SELECT name
FROM sys.views
ORDER BY name;
```

`sp_helptext` is useful for seeing the saved source code of a view, unless the view was created with `WITH ENCRYPTION`. `sys.views` lists view metadata. Because tables and views are both used in `SELECT`, the lesson recommends names like `vw_...` so developers can immediately identify a view.

## Important View Limitations

A view definition is not a general program. In these lessons, remember these restrictions:

- A view has no parameters.
- A view is not a place for `IF ELSE`, variables, loops, or procedural logic.
- A view definition cannot contain standalone `INSERT`, `UPDATE`, or `DELETE` statements.
- A normal view does not store a separate copy of data.
- You cannot create a view on a temporary table.
- A view definition should not depend on final display sorting; sort when you query the view.
- Expressions, constants, aggregates, and duplicate column names need clear aliases.

Example of aliases:

```sql
CREATE VIEW dbo.vw_balance_labels_lvw
AS
SELECT
    ACID,
    CUST_NAME,
    CBAL,
    CBAL * 0.01 AS ONE_PERCENT_OF_BALANCE,
    'BANK CUSTOMER' AS CUSTOMER_CATEGORY
FROM dbo.ACCOUNT_MASTER_VW;
GO
```

Without aliases, expression columns become hard to use and may fail when SQL Server requires a column name.

## Views Compared With Procedures And Functions

Views, stored procedures, and functions all help centralize logic, but they are not used the same way.

A view is called inside a `SELECT`:

```sql
SELECT *
FROM dbo.vw_br1_accounts_lvw;
```

An inline table-valued function can also be used inside `FROM`:

```sql
SELECT *
FROM dbo.fn_ActiveAccounts_LVW();
```

A stored procedure is called with `EXEC`, not with `SELECT FROM`:

```sql
EXEC dbo.usp_GetActiveAccounts_LVW;
```

This is why views and table-valued functions can be joined like tables, but stored procedures are not joined directly in a `SELECT` query.

## View With Table, View With View, And View On View

Because a view returns rows and columns, you can join it with a table when there is a meaningful common column.

```sql
SELECT
    a.ACID,
    a.CUST_NAME,
    a.BRID,
    b.BRANCH_NAME,
    b.BRANCH_CITY,
    a.CBAL
FROM dbo.vw_br1_accounts_lvw AS a
JOIN dbo.BRANCH_MASTER_VW AS b
    ON a.BRID = b.BRID;
```

You can also create a second view on top of a first view. In the transcript, this was explained with fixed deposit customers and then BR1 fixed deposit customers. In this setup, the same idea can be practiced with active accounts and branch-specific active accounts.

```sql
CREATE VIEW dbo.vw_active_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE STATUS = 'A';
GO

CREATE VIEW reporting_lvw.vw_br2_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, STATUS, CBAL
FROM dbo.vw_active_accounts_lvw
WHERE BRID = 'BR2';
GO
```

When reading someone else's view code, first identify the base object, then the main filter, then the joins, then the grouping. Do not get lost in every selected column first. Ask: what business result is this view trying to produce?

## Date Logic Used In The View Lessons

The view lessons use transaction-date examples such as current year, current month, current week, and last six months. For revision, know the common date functions:

- `GETDATE()` returns the current date and time.
- `CAST(GETDATE() AS DATE)` removes the time portion.
- `YEAR(date_column)` extracts the year.
- `MONTH(date_column)` extracts the month.
- `DATEADD(part, number, date)` adds or subtracts date parts.
- `DATEDIFF(part, start_date, end_date)` counts boundaries crossed between dates.

Current-year transaction view:

```sql
CREATE VIEW dbo.vw_current_year_txn_lvw
AS
SELECT TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT
FROM dbo.TRANSACTION_MASTER_VW
WHERE YEAR(TXN_DATE) = YEAR(GETDATE());
GO
```

No-transactions-in-last-six-months view:

```sql
CREATE VIEW dbo.vw_no_txn_last_6_months_lvw
AS
SELECT a.ACID, a.CUST_NAME, a.BRID, a.STATUS, a.CBAL
FROM dbo.ACCOUNT_MASTER_VW AS a
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.TRANSACTION_MASTER_VW AS t
    WHERE t.ACID = a.ACID
      AND t.TXN_DATE >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
);
GO
```

`NOT EXISTS` is usually safer than `NOT IN` when the subquery might contain `NULL`.

## Aggregates, GROUP BY, And HAVING In Views

Aggregate functions summarize many rows into one value:

- `COUNT(*)` counts rows.
- `COUNT(column)` counts non-null values in that column.
- `COUNT_BIG(*)` is like `COUNT(*)` but returns a larger integer type and is required in grouped indexed-view definitions.
- `SUM(column)` adds numeric values.
- `AVG(column)` gives the average.
- `MIN(column)` gives the smallest value.
- `MAX(column)` gives the largest value.

When you mix normal columns and aggregate functions, every normal selected column must usually appear in `GROUP BY`.

```sql
CREATE VIEW dbo.vw_branch_summary_lvw
AS
SELECT
    BRID,
    COUNT(*) AS ACCOUNT_COUNT,
    SUM(CBAL) AS TOTAL_BALANCE,
    AVG(CBAL) AS AVG_BALANCE,
    MIN(CBAL) AS MIN_BALANCE,
    MAX(CBAL) AS MAX_BALANCE
FROM dbo.ACCOUNT_MASTER_VW
GROUP BY BRID;
GO
```

Use `WHERE` before `GROUP BY` to filter individual rows. Use `HAVING` after `GROUP BY` to filter grouped results.

```sql
SELECT BRID, SUM(CBAL) AS ACTIVE_BALANCE
FROM dbo.ACCOUNT_MASTER_VW
WHERE STATUS = 'A'
GROUP BY BRID
HAVING SUM(CBAL) > 30000;
```

In the lesson context, aggregate views are treated as read-only. You can read the summary, but you do not update an aggregate row and expect SQL Server to know how to distribute that change across the base table.

## Updatable And Non-Updatable Views

An updatable view is a view through which SQL Server can translate an `INSERT`, `UPDATE`, or `DELETE` into the base table. In the beginner lesson, think of a simple one-table view with enough required columns.

```sql
CREATE VIEW dbo.vw_br1_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL, RMK
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';
GO
```

You can update rows through this kind of view:

```sql
UPDATE dbo.vw_br1_accounts_lvw
SET RMK = 'Updated through view'
WHERE ACID = 101;
```

You may also insert through it if the view includes all required base-table columns or the missing base-table columns allow `NULL` or defaults. If a view joins multiple tables, SQL Server cannot insert into all joined base tables with one simple insert. If a view contains aggregates, `GROUP BY`, or calculated summaries, treat it as non-updatable.

## WITH CHECK OPTION

A filtered view without `WITH CHECK OPTION` can accept a row that does not match the filter. For example, a BR1 view could be used to insert a BR3 row into the base table. The insert may succeed, but the row will not appear when you select from the BR1 view.

`WITH CHECK OPTION` protects against that. It says: if you insert or update through this view, the final row must still satisfy the view's `WHERE` clause.

```sql
CREATE VIEW dbo.vw_br1_accounts_check_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL, RMK
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1'
WITH CHECK OPTION;
GO
```

This is especially important when the view itself represents a business rule: "this screen is only for BR1 accounts", "this update page is only for Chennai employees", or "this view should only manage active records."

## Schema And Metadata

The transcripts use the word schema in two ways.

First, schema can mean metadata: table name, column names, data types, primary keys, foreign keys, nullability, and view/procedure/function definition code. If a base table column is renamed or dropped, dependent views can break because their saved definition still points to the old name.

Second, schema can mean object namespace, such as `dbo`, `sales`, `hr`, or `reporting_lvw`. Object schemas help group objects and manage security.

```sql
CREATE SCHEMA reporting_lvw;
GO

CREATE VIEW reporting_lvw.vw_active_accounts_lvw
AS
SELECT ACID, CUST_NAME, BRID, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE STATUS = 'A';
GO
```

If you do not specify a schema, SQL Server commonly uses `dbo` as the default object schema. For serious work, write schema-qualified names like `dbo.ACCOUNT_MASTER_VW`.

## WITH SCHEMABINDING

`WITH SCHEMABINDING` binds the view to the schema of the base object. It helps prevent accidental metadata changes that would break the view. If a schemabound view depends on `dbo.ACCOUNT_MASTER_VW`, SQL Server will not allow a dependent column or table to be dropped until the view is changed or dropped first.

```sql
CREATE VIEW dbo.vw_active_accounts_schema_lvw
WITH SCHEMABINDING
AS
SELECT ACID, CUST_NAME, BRID, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE STATUS = 'A';
GO
```

Important rules:

- Use two-part names like `dbo.ACCOUNT_MASTER_VW`.
- The view and referenced objects must be in the same database.
- `SCHEMABINDING` protects metadata changes, not row changes.
- You can still insert, update, or delete normal table data if other constraints allow it.

## WITH ENCRYPTION

`WITH ENCRYPTION` hides the stored view definition. After encryption, tools like designer and `sp_helptext` will not show the readable source in the normal way.

```sql
CREATE VIEW dbo.vw_br1_accounts_encrypted_lvw
WITH ENCRYPTION
AS
SELECT ACID, CUST_NAME, BRID, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';
GO
```

The practical warning is simple: keep a separate copy of the source before encrypting. Encryption may protect logic from casual viewing, but it can also hurt maintenance if the team loses the original script.

## Indexed Views

A normal view runs its query when you call it. This can become slow when the query is complex, joins large tables, groups data, and is called again and again. The lesson introduces indexed views for this case.

In SQL Server, an indexed view is created by making a view with `WITH SCHEMABINDING` and then creating a unique clustered index on it. The first index on the view must be unique and clustered. After that, SQL Server stores the view result in the database similarly to a table with a clustered index, and it maintains that result when base-table data changes.

Indexed views are useful for large, repeated, expensive summary queries, especially reporting or data-warehouse style workloads. They are not free. Inserts, updates, and deletes on the base tables may become slower because SQL Server must also maintain the indexed view.

```sql
SET NUMERIC_ROUNDABORT OFF;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE VIEW dbo.vw_branch_balance_indexed_lvw
WITH SCHEMABINDING
AS
SELECT
    BRID,
    COUNT_BIG(*) AS ACCOUNT_COUNT,
    SUM(CBAL) AS TOTAL_BALANCE
FROM dbo.ACCOUNT_MASTER_VW
GROUP BY BRID;
GO

CREATE UNIQUE CLUSTERED INDEX UX_vw_branch_balance_indexed_lvw
ON dbo.vw_branch_balance_indexed_lvw (BRID);
GO
```

For grouped indexed views, remember `COUNT_BIG(*)`. Also remember that SQL Server has stricter indexed-view rules than normal views, including required session `SET` options and deterministic expressions.

## Final Interview Answers

What is a view? A view is a saved `SELECT` query stored as a database object and used like a virtual table.

Does a normal view store data? No. It reads fresh data from base tables when queried.

Can a view be joined with a table? Yes, if there is a meaningful join condition.

Can a view be created on another view? Yes.

Can a stored procedure be joined in a `SELECT` query like a table? No. A stored procedure is executed with `EXEC`.

Can we insert through a view? Sometimes yes, if SQL Server can map the insert to the base table and required columns are handled.

Why use `WITH CHECK OPTION`? To make sure rows inserted or updated through a filtered view still satisfy that view's filter.

Why use `WITH SCHEMABINDING`? To stop base-object metadata changes that would break the view.

Why use `WITH ENCRYPTION`? To hide the view definition, but keep a script backup first.

What is an indexed view? A schemabound view with a unique clustered index whose result is physically stored and maintained by SQL Server for performance.

