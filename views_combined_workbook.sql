USE company;
GO

/*
Combined Views Workbook
Based on:
- 2_transcript.txt
- 3_transcript.txt
- 4_transcript.txt
- 05 SQL Server - Views Part4 - Schemas and Indexed Views.txt

Run views_combined_setup.sql first.

This workbook uses:
- dbo.BRANCH_MASTER_VW
- dbo.ACCOUNT_MASTER_VW
- dbo.TRANSACTION_MASTER_VW
- reporting_lvw schema
- dbo.fn_ActiveAccounts_LVW()
- dbo.usp_GetActiveAccounts_LVW

This workbook combines all the views lessons into one place.
It covers:
- what a view is and why we use it
- view limitations
- virtual table and fresh data idea
- updatable vs non-updatable views
- insert / update / delete through a view
- view with table, view with view, and view with function
- why a procedure cannot be used in SELECT
- view-on-view approach
- schema and metadata meaning
- WITH SCHEMABINDING
- WITH ENCRYPTION
- WITH CHECK OPTION
- indexed views / materialized view idea
*/

/*
==================================================
1. Current Lesson Topics From Transcript
==================================================
- view as a single query stored as a database object
- why views are used: centralization, security, reusability, focused output for portals / client apps
- view as a virtual table
- normal views always return fresh data from base tables
- limitations of views:
  single query, no parameters, no ORDER BY inside normal view definition,
  no defaults / triggers / constraints inside the view definition,
  no temporary views, no views on temporary tables
- explicit names required for expressions, constants, aggregates, and duplicate column names
- create / call / alter / drop view
- sp_helptext for reading view code
- sys.views for listing views
- sys.procedures for listing stored procedures
- view with table join
- view with view join
- view using another view
- view with function / UDF
- stored procedure cannot be used directly in SELECT
- updatable view vs non-updatable view
- insert / update / delete through an updatable view
- aggregate / GROUP BY views becoming read-only
- current year / current month / current quarter style transaction-view examples
- filtering with view but inserting other data when CHECK OPTION is not used
- applying WHERE / GROUP BY / HAVING / ORDER BY on top of a view result
- schema changes breaking dependent views, procedures, and functions
- impact analysis / risk analysis before changing base table schema
- WITH SCHEMABINDING
- schema name prefix requirement for schemabinding
- schema meaning in two ways:
  metadata / code and object schema like dbo / sales / hr
- WITH ENCRYPTION
- WITH CHECK OPTION
- indexed views / materialized view idea
- why indexed views help for large, complex, repeated queries
- COUNT_BIG and unique clustered index requirement in indexed-view example

==================================================
2. Previously Covered Topics Needed Here
==================================================
- SELECT, WHERE
- aliases
- joins
- subqueries / NOT EXISTS
- GROUP BY, HAVING
- aggregate functions
- GETDATE()
- YEAR() and date filtering ideas
- ORDER BY

==================================================
3. Important Points From Transcript
==================================================
- A view helps centralize reusable SQL in the database instead of leaving the query only in a query window.
- Views are often used by front-end portals, websites, and client applications.
- A normal view does not store a separate copy of the data; it runs the underlying query and returns fresh data.
- That is why a view is called a virtual table.
- A view can hide unnecessary columns and show only the subset needed by a branch, team, or report.
- A filtered view without CHECK OPTION can still accept rows that do not satisfy the filter; those rows go to the base table but may not appear in the filtered view later.
- Aggregate and GROUP BY based views are typically read-only in this lesson context.
- You can join a view with a table, another view, and a function / UDF.
- Stored procedures are different: they are executed with EXEC and are not used directly in SELECT.
- If base table names or column names change, dependent views can fail.
- The trainer strongly emphasized impact analysis before schema changes in real projects.
- SCHEMABINDING protects metadata from accidental changes, not normal row data operations.
- ENCRYPTION hides view source code; take a safe copy before using it.
- CHECK OPTION protects the view filter from being violated through the view.
- Indexed views are especially useful for complex, repeated queries on large data.

==================================================
4. Interview Tricks From Transcript
==================================================
- "Can I insert into a view?" usually means "Can I insert into the base table by using the view?"
- "Does a view store data?" is a trap question. Normal view: no. Indexed / materialized view idea: yes, output is stored / cached elsewhere.
- "Can we join a view and a table?" Yes.
- "Can we join a view and another view?" Yes.
- "Can we join a view and a function?" Yes, in this lesson's explanation.
- "Can we use a stored procedure in SELECT?" No.
- "Why did the view break?" often points to renamed / dropped base tables or columns.
- "What does schemabinding really block?" schema changes, not normal INSERT / UPDATE / DELETE on table data.
- "What happens after encryption?" designer / sp_helptext will not show the code in a readable way.
- "Why COUNT_BIG in indexed views?" that was the trainer's specific interview note for large-count / indexed-view examples.

==================================================
5. Common Mistakes / Warnings From Transcript
==================================================
- Do not think "single query" means "only simple query." A single query can still include joins, filters, aggregates, and ranking.
- Do not put ORDER BY inside a normal view definition in this lesson context.
- Do not forget aliases for expressions, constants, aggregates, or duplicate column names.
- Do not think normal views store data permanently.
- Do not assume filtered view means filtered insert behavior; without CHECK OPTION, unexpected rows can still be inserted through the view.
- Do not rename or drop base table columns casually in real projects.
- Do not encrypt a view without keeping a copy of the code.
- Do not confuse metadata schema with object schema like dbo.
- Do not try to use a stored procedure like a table in SELECT.

==================================================
6. Best Practices / Practical Tips From Transcript
==================================================
- Use views to centralize common query logic.
- Give views clear names; the trainer recommended prefixes like vw_ so developers can quickly recognize them.
- Give only view permission to application users where appropriate instead of exposing base tables directly.
- Apply ORDER BY outside the view when you query the view result.
- Before changing table schema, check which views, functions, procedures, reports, or apps depend on it.
- Use CHECK OPTION when the business rule says the view filter must stay valid during inserts or updates.
- Use indexed views only for justified cases such as complex, slow, repeated queries.
- Keep a copy of any encrypted view definition outside the database.

==================================================
7. SQL Rules / Query Rules / Interview Rules
==================================================
- A view is a single SELECT query stored as a database object.
- A normal view does not store a separate data copy; it returns fresh data from base tables.
- No parameters are allowed in a view.
- No ORDER BY inside a normal view definition in this lesson context.
- No temporary view is allowed in this lesson context.
- No view on a temporary table in this lesson context.
- No defaults, triggers, or constraints are written inside the view definition in this lesson context.
- If a view definition contains expressions, constants, aggregates, or duplicate column names, give explicit aliases.
- You cannot write INSERT / UPDATE / DELETE statements inside the view definition itself.
- After creating an updatable view, you may be able to do INSERT / UPDATE / DELETE through that view.
- An updatable view is usually based on one base table and should avoid aggregate / GROUP BY logic.
- If a view uses aggregate functions or GROUP BY, treat it as read-only for this lesson.
- A view can be built on another view.
- A view can join a table, another view, and a function / UDF.
- A stored procedure is executed with EXEC and is not used directly in SELECT.
- If a base table name or base column name changes, dependent views may fail.
- WITH SCHEMABINDING requires schema-prefixed object names such as dbo.ACCOUNT_MASTER_VW.
- SCHEMABINDING blocks metadata changes on dependent base objects until the view dependency is removed.
- SCHEMABINDING does not block normal row INSERT / UPDATE / DELETE in the base table.
- WITH ENCRYPTION hides the view definition.
- WITH CHECK OPTION prevents changes through the view that would make rows fall outside the view filter.
- Indexed-view example requires WITH SCHEMABINDING, COUNT_BIG, and a unique clustered index.

==================================================
8. Beginner-Friendly Notes
==================================================
What is a View?
- A view is a stored query.
- It behaves like a table when you select from it, so people call it a virtual table.

Why do we use it?
- To save reusable query logic in the database.
- To show only the needed columns / rows to users or applications.
- To keep base tables less exposed to front-end users.

Fresh Data Idea:
- Normal views do not keep their own data copy.
- Every time you run the view, SQL Server runs the underlying query and gives you current data.

Updatable vs Non-updatable:
- Filtered single-table views can often be used for INSERT / UPDATE / DELETE.
- Aggregate / GROUP BY views are treated as read-only in this lesson.

Schema Word in Two Meanings:
- Meaning 1: metadata / code like table name, column name, datatype, keys.
- Meaning 2: object schema like dbo, sales, hr.

Indexed View Idea:
- Normal view: query runs again and again.
- Indexed view: result is stored / cached elsewhere for faster repeated access.

Practical SQL Server Note Beyond Transcript:
- Indexed-view creation can depend on session settings in SQL Server tools.
- If an indexed-view creation step fails due to settings, ensure these are used in that session:
  SET ANSI_NULLS ON;
  SET QUOTED_IDENTIFIER ON;
  SET ANSI_PADDING ON;
  SET ANSI_WARNINGS ON;
  SET CONCAT_NULL_YIELDS_NULL ON;
  SET ARITHABORT ON;
  SET NUMERIC_ROUNDABORT OFF;

==================================================
9. Syntax Section
==================================================

Create a simple filtered view:
CREATE VIEW dbo.vw_br1_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';

Call a view:
SELECT *
FROM dbo.vw_br1_accounts_lvw;

Sort outside the view:
SELECT *
FROM dbo.vw_br1_accounts_lvw
ORDER BY CBAL DESC;

Alter a view:
ALTER VIEW dbo.vw_br1_accounts_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL, EMAIL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';

Drop a view:
DROP VIEW dbo.vw_br1_accounts_lvw;

Read view code:
EXEC sp_helptext 'dbo.vw_br1_accounts_lvw';

List views:
SELECT name
FROM sys.views
ORDER BY name;

Count views:
SELECT COUNT(*) AS VIEW_COUNT
FROM sys.views;

List stored procedures:
SELECT name
FROM sys.procedures
ORDER BY name;

Create a non-updatable summary view:
CREATE VIEW dbo.vw_branch_summary_lvw
AS
SELECT BRID, COUNT(*) AS CUSTOMER_COUNT
FROM dbo.ACCOUNT_MASTER_VW
GROUP BY BRID;

Create a current-year transaction view:
CREATE VIEW dbo.vw_current_year_txn_lvw
AS
SELECT TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT
FROM dbo.TRANSACTION_MASTER_VW
WHERE YEAR(TXN_DATE) = YEAR(GETDATE());

Current-month idea:
SELECT TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT
FROM dbo.TRANSACTION_MASTER_VW
WHERE YEAR(TXN_DATE) = YEAR(GETDATE())
  AND MONTH(TXN_DATE) = MONTH(GETDATE());

Current-quarter idea:
SELECT TXNID, ACID, TXN_DATE, TXN_TYPE, AMOUNT
FROM dbo.TRANSACTION_MASTER_VW
WHERE YEAR(TXN_DATE) = YEAR(GETDATE())
  AND DATEPART(QUARTER, TXN_DATE) = DATEPART(QUARTER, GETDATE());

Create a view on another view:
CREATE VIEW dbo.vw_current_year_account_txn_lvw
AS
SELECT t.TXNID, t.ACID, a.CUST_NAME, a.BRID, t.TXN_DATE, t.TXN_TYPE, t.AMOUNT
FROM dbo.vw_current_year_txn_lvw AS t
INNER JOIN dbo.ACCOUNT_MASTER_VW AS a
    ON t.ACID = a.ACID;

Join a view with a table:
SELECT v.ACID, v.CUST_NAME, b.BRANCH_NAME
FROM dbo.vw_br1_accounts_lvw AS v
INNER JOIN dbo.BRANCH_MASTER_VW AS b
    ON v.BRID = b.BRID;

Create a schema-bound view:
CREATE VIEW dbo.vw_active_accounts_schema_lvw
WITH SCHEMABINDING
AS
SELECT ACID, CUST_NAME, BRID, CBAL, STATUS
FROM dbo.ACCOUNT_MASTER_VW
WHERE STATUS = 'A';

Create an encrypted view:
CREATE VIEW dbo.vw_br1_accounts_encrypted_lvw
WITH ENCRYPTION
AS
SELECT ACID, CUST_NAME, BRID, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1';

Create a filtered view with check option:
CREATE VIEW dbo.vw_br1_accounts_check_lvw
AS
SELECT ACID, CUST_NAME, CITY, BRID, ACCOUNT_TYPE, DOO, STATUS, CBAL
FROM dbo.ACCOUNT_MASTER_VW
WHERE BRID = 'BR1'
WITH CHECK OPTION;

Use a function in SELECT:
SELECT *
FROM dbo.fn_ActiveAccounts_LVW();

Call a stored procedure:
EXEC dbo.usp_GetActiveAccounts_LVW;

Create an indexed-view example:
CREATE VIEW dbo.vw_branch_balance_indexed_lvw
WITH SCHEMABINDING
AS
SELECT BRID,
       COUNT_BIG(*) AS ACCOUNT_COUNT,
       SUM(CBAL) AS TOTAL_BALANCE
FROM dbo.ACCOUNT_MASTER_VW
GROUP BY BRID;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vw_branch_balance_indexed_lvw
ON dbo.vw_branch_balance_indexed_lvw (BRID);
GO

==================================================
10. Level 1: Basic Questions
==================================================
Write your answers below each question.
*/

-- L1-Q1. Create dbo.vw_active_accounts_lvw to show all columns from active accounts only.


-- L1-Q2. Call dbo.vw_active_accounts_lvw and sort the result by CBAL in descending order.


-- L1-Q3. Alter dbo.vw_active_accounts_lvw so it returns only:
-- ACID, CUST_NAME, BRID, CBAL, STATUS


-- L1-Q4. Use sp_helptext to see the code of dbo.vw_active_accounts_lvw.


-- L1-Q5. Show all view names from sys.views.


-- L1-Q6. Show all stored procedure names from sys.procedures.


-- L1-Q7. Create dbo.vw_current_year_txn_lvw to show only current-year transactions.


-- L1-Q8. Create dbo.vw_branch_summary_lvw with:
-- BRID, COUNT(*) AS CUSTOMER_COUNT


-- L1-Q9. Write a comment answer:
-- Why is a view called a virtual table?


-- L1-Q10. Write a comment answer:
-- Can ORDER BY be kept inside a normal view definition in this lesson context?


-- L1-Q11. Write a comment answer:
-- Do normal views store data separately?


/*
==================================================
11. Level 2: Intermediate Questions
==================================================
*/

-- L2-Q1. Create dbo.vw_br1_accounts_lvw to show all columns from BR1 accounts.


-- L2-Q2. Insert one new BR1 row through dbo.vw_br1_accounts_lvw.
-- Use a new ACID value not already present in the table.


-- L2-Q3. Insert one BR3 row through the same dbo.vw_br1_accounts_lvw
-- and then query both the base table and the view to observe the behavior.
-- This question is meant to show what happens when CHECK OPTION is not used.


-- L2-Q4. Create dbo.vw_no_txn_last_6_months_lvw
-- to show customers who did not do any transaction in the last 6 months.


-- L2-Q5. Join dbo.vw_br1_accounts_lvw with dbo.BRANCH_MASTER_VW
-- and show ACID, CUST_NAME, BRID, BRANCH_NAME.


-- L2-Q6. Create dbo.vw_current_year_account_txn_lvw
-- by joining dbo.vw_current_year_txn_lvw with dbo.ACCOUNT_MASTER_VW.
-- Show TXNID, ACID, CUST_NAME, BRID, TXN_DATE, TXN_TYPE, AMOUNT.


-- L2-Q7. On top of dbo.vw_current_year_account_txn_lvw,
-- write a query with GROUP BY and HAVING to show branches
-- whose current-year total transaction amount is greater than 5000.


-- L2-Q8. Create reporting_lvw.vw_br2_accounts_lvw
-- to show ACID, CUST_NAME, BRID, CBAL for BR2 accounts.


-- L2-Q9. Create dbo.vw_balance_labels_lvw using:
-- CBAL * 0.05 AS BONUS_AMOUNT
-- 'VISIBLE' AS VIEW_LABEL
-- Make sure you give explicit aliases.


/*
==================================================
12. Level 3: Interview-Style Questions
==================================================
*/

-- L3-Q1. Create dbo.vw_br1_accounts_check_lvw with WITH CHECK OPTION.


-- L3-Q2. Write a comment answer:
-- What should happen if someone tries to insert a BR3 row
-- through dbo.vw_br1_accounts_check_lvw?


-- L3-Q3. Create dbo.vw_active_accounts_schema_lvw with WITH SCHEMABINDING.
-- Use only schema-prefixed base object names and explicit column list.


-- L3-Q4. Write a comment answer:
-- After SCHEMABINDING, what metadata changes are blocked?
-- What data changes are still allowed?


-- L3-Q5. Create dbo.vw_br1_accounts_encrypted_lvw with WITH ENCRYPTION.


-- L3-Q6. Write the verification statement(s) you would use
-- to check what happens to the view code after encryption.


-- L3-Q7. Create dbo.vw_branch_balance_indexed_lvw using:
-- BRID, COUNT_BIG(*) AS ACCOUNT_COUNT, SUM(CBAL) AS TOTAL_BALANCE
-- and WITH SCHEMABINDING.


-- L3-Q8. Create a unique clustered index on dbo.vw_branch_balance_indexed_lvw (BRID).


-- L3-Q9. Write a comment answer:
-- Compare normal view vs indexed / materialized view.


-- L3-Q10. Write a comment answer:
-- Can a stored procedure be used directly in SELECT or joined like a view / function?


/*
==================================================
13. Level 4: Real-World / Business-Style Questions
==================================================
*/

-- L4-Q1. A branch manager should see only BR1 customer data.
-- Create a view that exposes only:
-- ACID, CUST_NAME, CITY, CBAL


-- L4-Q2. Finance team wants current-year transaction details with customer names.
-- Use a view-on-view approach and return customer name, branch, date, type, amount.


-- L4-Q3. Audit team wants customers who had no transaction in the last 6 months
-- along with the branch name. Write the query using your view plus the branch table.


-- L4-Q4. Write a comment answer:
-- Before renaming CUST_NAME in dbo.ACCOUNT_MASTER_VW,
-- what impact analysis / risk analysis should a DBA think about?


-- L4-Q5. Reporting team says branch-wise balance summary is slow and queried again and again.
-- Which view type is more suitable here and why?
-- Also write the SQL pattern using lesson objects.


/*
==================================================
14. Level 5: Rapid Revision
==================================================
Keep answers short.
*/

-- L5-Q1. Write the syntax to drop dbo.vw_active_accounts_lvw.


-- L5-Q2. Write the syntax to alter dbo.vw_active_accounts_lvw.


-- L5-Q3. Write a comment answer:
-- Can a view have parameters?


-- L5-Q4. Write a comment answer:
-- Can we create a temporary view?


-- L5-Q5. Write a comment answer:
-- Can we create a view on a temporary table?


-- L5-Q6. Write a comment answer:
-- Are defaults, triggers, and constraints written inside a normal view definition in this lesson context?


-- L5-Q7. Write a comment answer:
-- Can a view join another view?


-- L5-Q8. Write a small query that uses dbo.fn_ActiveAccounts_LVW().


-- L5-Q9. Write the statement to call dbo.usp_GetActiveAccounts_LVW.


-- L5-Q10. Write a comment answer:
-- What does dbo represent here?


-- L5-Q11. Write a comment answer:
-- What does WITH CHECK OPTION protect?


-- L5-Q12. Write a comment answer:
-- What extra things are needed to make an indexed view in this lesson?


-- L5-Q13. Write a query for current-quarter transactions
-- using dbo.TRANSACTION_MASTER_VW.


/*
==================================================
15. Mixed Interview Practice
==================================================
These combine previous topics with current view topics.
*/

-- MIP-Q1. Create dbo.vw_current_year_branch_amount_lvw
-- on top of dbo.vw_current_year_account_txn_lvw
-- to show BRID and SUM(AMOUNT) AS TOTAL_AMOUNT.


-- MIP-Q2. Write a query that joins dbo.vw_br1_accounts_lvw
-- with dbo.fn_ActiveAccounts_LVW() and shows matching ACID, CUST_NAME, CBAL.


-- MIP-Q3. Write a comment answer:
-- Why does EXEC dbo.usp_GetActiveAccounts_LVW work,
-- but SELECT * FROM dbo.usp_GetActiveAccounts_LVW does not?


-- MIP-Q4. Query dbo.vw_branch_balance_indexed_lvw
-- and order the rows by TOTAL_BALANCE descending.


/*
==================================================
16. Optional Challenge Questions
==================================================
*/

-- OC-Q1. Build a view on top of a view that shows only current-year Cash Deposit rows
-- and includes customer name and branch name.


-- OC-Q2. Create one non-updatable view using aggregate / GROUP BY
-- and write a comment explaining why INSERT / UPDATE / DELETE should not be used on it.


-- OC-Q3. Write a short comparison comment between:
-- dbo.vw_br1_accounts_lvw
-- dbo.vw_br1_accounts_check_lvw
-- Use the same BR3-insert scenario to explain the difference.


-- OC-Q4. Write a comment-only matrix for:
-- view, stored procedure, function
-- Mention whether each one can be:
-- called in SELECT
-- joined in SELECT
-- executed with EXEC


/*
==================================================
17. Transcript Coverage Checklist
==================================================
Current transcript topics covered in this workbook:
- what a view is and why it is used
- virtual table idea
- fresh-data behavior of normal views
- limitations of views
- aliasing requirements for expressions / constants / aggregates / duplicate names
- create / call / alter / drop view
- sp_helptext
- sys.views
- sys.procedures
- view with table / view / function
- procedure vs view / function in SELECT
- updatable vs non-updatable views
- insert / update / delete through view
- current year / current month / current quarter filtering examples
- filtered view behavior without CHECK OPTION
- applying WHERE / GROUP BY / HAVING / ORDER BY on top of a view result
- impact analysis before schema changes
- WITH SCHEMABINDING
- schema name prefix requirement
- schema meaning as metadata and as dbo / custom schema
- WITH ENCRYPTION
- WITH CHECK OPTION
- indexed view / materialized view idea
- COUNT_BIG and unique clustered index requirement

Previous topics reused for practice:
- SELECT, WHERE
- JOIN
- NOT EXISTS
- GROUP BY / HAVING
- aliases
- aggregate functions
- YEAR() / GETDATE()
- ORDER BY

Future topics only mentioned but not deeply taught in these view transcripts:
- deeper stored procedure topic
- deeper function topic
- detailed schema security topic
- detailed index internals topic
- broader OLTP / OLAP / data warehouse architecture

Setup file created for this combined lesson:
- views_combined_setup.sql

Important transcript points captured even when not always turned into separate SQL execution questions:
- portal / client application usage of views
- give applications permission on views instead of direct table access where appropriate
- take a backup of code before WITH ENCRYPTION
- schema changes can break views, procedures, functions, reports, and apps
- SCHEMABINDING blocks metadata changes, not row-data changes
*/
