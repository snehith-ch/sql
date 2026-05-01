# SQL Server Indexing - Combined Revision Notebook

Based on:
- `11_transcript.txt`
- `12_transcript.txt`
- `13 SQL Server - Indexes Part3.txt`

Run `indexing_combined_setup.sql` first. The examples use `company`, `dbo.IDX_EMP_HEAP`, `dbo.IDX_EMP_CLUSTERED`, and `dbo.IDX_ACCOUNT_MASTER`.

## Quick Revision

An index is an on-disk structure that helps SQL Server find rows faster. Without a useful index, SQL Server may scan the table row by row. The trainer calls this table scanning: start from the first row, check every row, and continue until the needed row is found or the table is finished.

A table without a clustered index is called a heap. In a heap, data rows are not stored in clustered-key order. Inserts can be simple, but random searches can be slow because SQL Server has less structure to navigate.

SQL Server has two core rowstore index types in these lessons:

- Clustered index: sorts and stores the table rows by the index key. Only one clustered index can exist per table because the table rows can be stored in only one physical order.
- Nonclustered index: a separate index structure with key values and row locators pointing to the actual rows. A table can have many nonclustered indexes.

Primary key and unique constraints create indexes automatically. A primary key creates a clustered index by default when no clustered index already exists. A unique constraint creates a unique nonclustered index by default. If a clustered index already exists and you add a primary key later, SQL Server can enforce that primary key with a nonclustered index.

Important syntax:

```sql
EXEC sp_helpindex 'dbo.IDX_EMP_CLUSTERED';

CREATE CLUSTERED INDEX IX_Table_Column
ON dbo.TableName (ColumnName);

CREATE NONCLUSTERED INDEX IX_Table_Column
ON dbo.TableName (ColumnName);

DROP INDEX IX_Table_Column ON dbo.TableName;
```

Use indexes for frequent selective reads. Be careful with too many indexes on write-heavy tables because inserts, updates, and deletes must also maintain indexes.

## Why Indexes Are Needed

When a table has only a few rows, a scan may be fine. But real systems can have thousands, millions, or billions of rows. A query like this should return quickly:

```sql
SELECT CBAL
FROM dbo.IDX_ACCOUNT_MASTER
WHERE ACID = 101;
```

If SQL Server has to check every account row one by one, the user may wait too long. An index gives SQL Server a better path. The transcript compares this to a book's table of contents or a warehouse index: instead of searching every room, first check the index page, then jump to the correct place.

Indexes improve lookup speed by giving the optimizer more choices. The query optimizer can choose a table scan, index scan, index seek, or other access method depending on the query and table statistics.

## Heap And Table Scan

A heap is a table without a clustered index.

```sql
SELECT *
FROM dbo.IDX_EMP_HEAP;

EXEC sp_helpindex 'dbo.IDX_EMP_HEAP';
```

`sp_helpindex` will show no indexes for the heap table in the setup. If you search the heap:

```sql
SELECT *
FROM dbo.IDX_EMP_HEAP
WHERE EMP_ID = 87;
```

SQL Server may scan the table. In a scan, it checks rows until it finds matching rows. A scan is not always evil. It can be reasonable when the table is small, when the query needs most or all rows, or when no useful index exists. But for large random lookups, scans are often slow.

## When SQL Server May Not Use An Index

The transcripts highlight three beginner cases:

- The query reads all or most rows.
- The table is very small.
- No useful index exists for the query predicate.

Example:

```sql
SELECT *
FROM dbo.IDX_ACCOUNT_MASTER;
```

This needs all rows, so an index may not help much. Another example:

```sql
SELECT *
FROM dbo.IDX_ACCOUNT_MASTER
WHERE BRID = 'BR1';
```

If there is no index on `BRID`, the primary-key index on `ACID` may not help because the query is filtering by branch, not account id.

## Clustered Index

A clustered index sorts and stores the actual table rows by the clustered index key. In the setup, `IDX_EMP_CLUSTERED` has a primary key on `EMP_ID`, so SQL Server creates a clustered index by default.

```sql
EXEC sp_helpindex 'dbo.IDX_EMP_CLUSTERED';

SELECT *
FROM dbo.IDX_EMP_CLUSTERED
WHERE EMP_ID = 87;
```

The clustered index has a B-tree style structure. The trainer describes root node, intermediate nodes, and leaf nodes. The important interview point is:

- Root and intermediate levels contain index pages.
- The leaf level of a clustered index contains the actual data pages.

Because the leaf level contains the table data, one table can have only one clustered index. The data rows cannot be physically stored in two different orders at the same time.

## Why Primary Key Creates An Index

Primary keys and unique keys must check duplicates. If SQL Server had no index, checking whether a new key already exists could require scanning a large table. By creating an index automatically, SQL Server can quickly check whether the key value already exists.

```sql
INSERT INTO dbo.IDX_EMP_CLUSTERED
    (EMP_ID, EMP_NAME, CITY, GENDER, SALARY)
VALUES
    (87, 'Duplicate', 'Pune', 'M', 10000);
```

This fails because the primary key prevents duplicate `EMP_ID`. The clustered index helps SQL Server enforce that rule efficiently.

## Clustered Index Without Primary Key

A clustered index and a primary key are related but not the same thing. A primary key is a constraint. A clustered index is a storage/access structure.

You can create a clustered index manually:

```sql
CREATE CLUSTERED INDEX IX_IDX_EMP_HEAP_EMP_ID
ON dbo.IDX_EMP_HEAP (EMP_ID);
```

If the clustered index is not unique, duplicate key values are allowed. The index sorts rows by the key, but it does not enforce primary-key rules unless it is unique or created by a primary key/unique constraint.

## Nonclustered Index

A nonclustered index is separate from the table data. It stores index key values and row locators that point to the actual rows. If the base table has a clustered index, the row locator points through the clustered key. If the base table is a heap, the row locator points to the row location in the heap.

Create a nonclustered index:

```sql
CREATE NONCLUSTERED INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER (BRID);
```

Now this query has a better index candidate:

```sql
SELECT ACID, CUST_NAME, BRID, CBAL
FROM dbo.IDX_ACCOUNT_MASTER
WHERE BRID = 'BR1';
```

Use nonclustered indexes for frequent searches not covered by the clustered index, such as `CITY`, `BRID`, `EMAIL`, or another commonly filtered column.

## Unique And Non-Unique Indexes

Indexes can be unique or non-unique.

A unique index does not allow duplicate key values:

```sql
CREATE UNIQUE NONCLUSTERED INDEX UX_IDX_EMP_HEAP_EMP_NAME
ON dbo.IDX_EMP_HEAP (EMP_NAME);
```

A non-unique index allows duplicates:

```sql
CREATE NONCLUSTERED INDEX IX_IDX_EMP_HEAP_CITY
ON dbo.IDX_EMP_HEAP (CITY);
```

This difference matters in interviews. A clustered index does not automatically mean no duplicates. A primary key prevents duplicates. A unique index prevents duplicates. A plain clustered or nonclustered index can allow duplicates.

## Execution Plan: Scan Vs Seek

In SSMS, enable the actual execution plan before running a query. The transcript points out these terms:

- Table Scan: SQL Server scans a heap row by row.
- Clustered Index Scan: SQL Server scans the clustered index/table rows. This is still scan-style reading.
- Index Scan: SQL Server scans an index.
- Index Seek: SQL Server uses an index to directly find a range or exact key area. This is usually the desired access pattern for selective queries.

Example before and after indexing:

```sql
SELECT *
FROM dbo.IDX_ACCOUNT_MASTER
WHERE BRID = 'BR1';

CREATE NONCLUSTERED INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER (BRID);

SELECT *
FROM dbo.IDX_ACCOUNT_MASTER
WHERE BRID = 'BR1';
```

The exact plan can vary, especially with small tables, but the goal is to understand why a useful index gives the optimizer another option.

## Covered Index

A covered index is a nonclustered index that contains all columns needed by a query. SQL Server can answer the query from the index pages without going back to the base table or clustered index data pages.

```sql
CREATE NONCLUSTERED INDEX IX_IDX_ACCOUNT_MASTER_CITY_COVER
ON dbo.IDX_ACCOUNT_MASTER (CITY)
INCLUDE (ACID, CUST_NAME, CBAL);
```

This query can be covered by that index:

```sql
SELECT ACID, CUST_NAME, CBAL
FROM dbo.IDX_ACCOUNT_MASTER
WHERE CITY = 'Hyderabad';
```

The key column `CITY` helps search. The included columns `ACID`, `CUST_NAME`, and `CBAL` help return the selected data without needing extra lookups. Covered indexes can be fast, but they still take space and must be maintained during writes.

## When To Use Clustered Vs Nonclustered

Clustered indexes are commonly useful for range queries:

```sql
SELECT *
FROM dbo.IDX_EMP_CLUSTERED
WHERE EMP_ID BETWEEN 20 AND 100;
```

Because data is stored by clustered key order, SQL Server can find the start of the range and read forward.

Nonclustered indexes are commonly useful for exact matches or alternate search columns:

```sql
SELECT *
FROM dbo.IDX_ACCOUNT_MASTER
WHERE CITY = 'Mumbai';
```

The design is not automatic. Choose indexes based on real query patterns: columns used in `WHERE`, `JOIN`, `ORDER BY`, and sometimes selected output columns.

## Write Cost, Fragmentation, Rebuild, And Reorganize

Indexes speed reads, but they slow writes. Every `INSERT`, `UPDATE`, or `DELETE` may need to update the table and one or more indexes.

When many rows are inserted, updated, or deleted, index pages can become fragmented. The transcript explains fragmentation as gaps in the pages after data changes. SQL Server supports index maintenance:

```sql
ALTER INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER
REORGANIZE;

ALTER INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER
REBUILD;
```

`REORGANIZE` is a lighter online defragment-style operation. `REBUILD` recreates the index structure. In production, index maintenance should be scheduled and measured, not done randomly.

## Bulk Load Advice

If you load a very large amount of data into a destination table, indexes, triggers, and constraints can slow the load because SQL Server must maintain or validate them for many rows. The transcript's advice is to consider disabling or dropping nonessential indexes during large loads, then rebuild them afterward.

Be careful: do not disable constraints or indexes blindly in production. Understand the data quality risk, locking, downtime, and recovery plan.

Common commands:

```sql
ALTER INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER
DISABLE;

ALTER INDEX IX_IDX_ACCOUNT_MASTER_BRID
ON dbo.IDX_ACCOUNT_MASTER
REBUILD;
```

Rebuilding enables a disabled index.

## Final Interview Answers

What is a heap? A table without a clustered index.

What is table scanning? Reading rows one by one to find matching rows.

Why create indexes? To speed up data retrieval by giving SQL Server a better access path.

When are indexes bad? On heavy write operations or poorly chosen indexes, because every write must maintain the indexes.

How many clustered indexes per table? One.

Why only one clustered index? The actual data rows can be stored in only one key order.

How many nonclustered indexes per table? Up to 999 in SQL Server, including those created by primary key or unique constraints.

What does the clustered index leaf node contain? Actual data rows/pages.

What does a nonclustered index contain? Key values plus row locators pointing to the base rows.

Can a clustered index allow duplicates? Yes, if it is not unique. Primary key/unique constraints are what enforce uniqueness.

Can you drop the index created by a primary key while keeping the primary key? No. Drop/change the constraint instead.

What is a covered index? A nonclustered index that contains all columns needed by a query, so the query can be answered from the index.

