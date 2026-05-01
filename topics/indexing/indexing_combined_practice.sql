USE company;
GO

/*
Indexing Combined Practice

Run order:
1. Run indexing_combined_setup.sql.
2. Read indexing_combined_revision_notebook.md.
3. Solve this file.

These questions practice the same indexing concepts as the lessons,
but the exact questions are different.
*/

/*
==================================================
Level 1 - Heap And Existing Indexes
==================================================
*/

-- Q1. Use sp_helpindex to check indexes on dbo.IDX_EMP_HEAP.
-- TODO:


-- Q2. Use sp_helpindex to check indexes on dbo.IDX_EMP_CLUSTERED.
-- TODO:


-- Q3. Select all rows from dbo.IDX_EMP_HEAP.
-- In a comment, explain why the row order should not be trusted without ORDER BY.
-- TODO:


/*
==================================================
Level 2 - Clustered Index
==================================================
*/

-- Q4. Create a clustered index on dbo.IDX_EMP_HEAP using EMP_ID.
-- Name it IX_IDX_EMP_HEAP_EMP_ID.
-- TODO:


-- Q5. Use sp_helpindex again on dbo.IDX_EMP_HEAP.
-- TODO:


-- Q6. Try to create another clustered index on dbo.IDX_EMP_HEAP using CITY.
-- Keep the failing statement commented after testing.
-- In a comment, explain why only one clustered index is allowed.
-- TODO:


/*
==================================================
Level 3 - Nonclustered Index
==================================================
*/

-- Q7. Create a nonclustered index on dbo.IDX_ACCOUNT_MASTER using BRID.
-- Name it IX_IDX_ACCOUNT_MASTER_BRID.
-- TODO:


-- Q8. Query accounts where BRID = 'BR1'.
-- If you are using SSMS, enable Actual Execution Plan and observe scan/seek behavior.
-- TODO:


-- Q9. Create a nonclustered index on dbo.IDX_ACCOUNT_MASTER using CITY.
-- Name it IX_IDX_ACCOUNT_MASTER_CITY.
-- TODO:


-- Q10. Query accounts where CITY = 'Mumbai'.
-- TODO:


/*
==================================================
Level 4 - Unique And Duplicate Behavior
==================================================
*/

-- Q11. Insert a duplicate EMP_ID into dbo.IDX_EMP_HEAP.
-- Does it work after creating a non-unique clustered index?
-- Write your answer in a comment.
-- TODO:


-- Q12. Try to insert a duplicate ACID into dbo.IDX_ACCOUNT_MASTER.
-- Keep the failing statement commented after testing.
-- In a comment, explain whether the primary key or the index blocks it.
-- TODO:


-- Q13. Try to insert a duplicate EMAIL into dbo.IDX_ACCOUNT_MASTER.
-- Keep the failing statement commented after testing.
-- In a comment, explain what the UNIQUE constraint does.
-- TODO:


/*
==================================================
Level 5 - Covered Index
==================================================
*/

-- Q14. Create a covered nonclustered index named IX_IDX_ACCOUNT_MASTER_CITY_COVER.
-- Key column: CITY.
-- Included columns: ACID, CUST_NAME, CBAL.
-- TODO:


-- Q15. Write a query that can be covered by IX_IDX_ACCOUNT_MASTER_CITY_COVER:
-- select ACID, CUST_NAME, CBAL where CITY = 'Hyderabad'.
-- TODO:


-- Q16. In a comment, explain why SELECT * is usually not a covered query
-- for a narrow nonclustered index.
-- TODO:


/*
==================================================
Level 6 - Range Vs Exact Match
==================================================
*/

-- Q17. Write a range query on dbo.IDX_EMP_CLUSTERED using EMP_ID BETWEEN 20 AND 100.
-- TODO:


-- Q18. Write an exact-match query on dbo.IDX_ACCOUNT_MASTER using BRID = 'BR2'.
-- TODO:


-- Q19. In a comment, explain why clustered indexes are often useful for range searches
-- and nonclustered indexes are often useful for alternate exact-match columns.
-- TODO:


/*
==================================================
Level 7 - Drop, Disable, Rebuild, Reorganize
==================================================
*/

-- Q20. Drop the nonclustered index IX_IDX_ACCOUNT_MASTER_CITY if it exists.
-- TODO:


-- Q21. Disable IX_IDX_ACCOUNT_MASTER_BRID.
-- Then rebuild it to enable it again.
-- TODO:


-- Q22. Reorganize IX_IDX_ACCOUNT_MASTER_CITY_COVER.
-- TODO:


/*
==================================================
Level 8 - Metadata
==================================================
*/

-- Q23. Query sys.indexes for all indexes on dbo.IDX_ACCOUNT_MASTER.
-- Show index name, type_desc, and is_unique.
-- TODO:


-- Q24. In a comment, explain the difference between an Index Scan and an Index Seek.
-- TODO:


/*
==================================================
Level 9 - Cleanup
==================================================
*/

-- Q25. Drop only the practice indexes you created in this file.
-- Keep this section commented until you finish practicing.
-- TODO:

