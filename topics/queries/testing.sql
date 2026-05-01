USE company
GO

CREATE TABLE product
(
    PID      int           primary key     identity(1,1),
    prodName varchar(100)  not null,
    Qty      int           null             default(0),
    Unitprice money        not null 
)
GO

-- find schema of product table
sp_help product
GO

select * from product
go

--implicit insert
insert into product values ('pen', 1000, 10)
insert into product values ('pencil', 2000, 5)
insert into product values ('eraser', 3000, 2)

--add new column
alter table product add rating TINYINT

--update the data in the new column
update product set rating = 4 where PID = 1
update product set rating = 3 where PID = 2
update product set rating = 5 where PID > 2

--drop column from table
alter table product drop column rating


--last inserted identity value
select @@IDENTITY
GO

--delete all rows from product
delete from product

--delete only one row from product
delete from product where PID = 3

--to rollback delete operation

--no default value for Qty
insert into product values ('marker', null, 5000)

--default value for Qty
insert into product values ('rin', '',5000)

--explicit insert with default value for Qty
insert into product (prodName, Unitprice) values ('hp laptop', 5000)

--delete all rows using truncate
truncate table product


--drop table
drop table product