use company
go

create table AMASTER
(
    ACID int primary key,
    NAME varchar(50) not null,
    ADDRESS varchar(20) not null,
    BRID char(3) not null,
    PID CHAR(2),
    DOO date not null,
    CBAL decimal(18, 2) not null,
    UBAL decimal(18, 2) not null,
    STATUS CHAR(1) not null 
);

insert into AMASTER values (1, 'John Doe', '123 Main St', 'NYC', '01', '2020-01-01', 1000.00, 1000.00, 'A');
insert into AMASTER values (2, 'Jane Smith', '456 Elm St', 'LA', '02', '2020-02-01', 2000.00, 2000.00, 'A');
insert into AMASTER values (3, 'Bob Johnson', '789 Oak St', 'CHI    ', '03', '2020-03-01', 1500.00, 1500.00, 'A');
insert into AMASTER values (4, 'Alice Brown', '321 Pine St', 'HOU', '04', '2020-04-01', 2500.00, 2500.00, 'A');
insert into AMASTER values (5, 'Charlie Davis', '654 Cedar St', 'PH ', '05', '2020-05-01', 3000.00, 3000.00, 'A');
insert into AMASTER values (6, 'Eve Wilson', '987 Spruce St', 'PH ', '06', '2020-06-01', 3500.00, 3500.00, 'A')
insert into AMASTER values (7, 'Frank Miller', '246 Maple St', 'NYC', '07', '2020-07-01', 4000.00, 4000.00, 'A')
insert into AMASTER values (8, 'Grace Lee', '135 Birch St', 'LA', '08', '2020-08-01', 4500.00, 4500.00, 'A')
insert into AMASTER values (9, 'Hank Green', '864 Walnut St', 'CHI    ', '09', '2020-09-01', 5000.00, 5000.00, 'A')
insert into AMASTER values (10, 'Ivy White', '753 Chestnut St', 'HOU', '10', '2020-10-01', 5500.00, 5500.00, 'A')
insert into AMASTER values (11, 'Jack Black', '159 Cedar St', 'PH ', '11', '2020-11-01', 6000.00, 6000.00, 'A')
insert into AMASTER values (12, 'Karen Gray', '753 Pine St', 'NYC', '12', '2020-12-01', 6500.00, 6500.00, 'A')
insert into AMASTER values (13, 'Leo King', '321 Oak St', 'LA', '13', '2021-01-01', 7000.00, 7000.00, 'A')
insert into AMASTER values (14, 'Mia Scott', '654 Maple St', 'CHI    ', '14', '2021-02-01', 7500.00, 7500.00, 'A')
insert into AMASTER values (15, 'Nina Adams', '987 Birch St', 'HOU', '15', '2021-03-01', 8000.00, 8000.00, 'A')
insert into AMASTER values (16, 'Oscar Brown', '246 Walnut St', 'PH ', '16', '2021-04-01', 8500.00, 8500.00, 'A')
insert into AMASTER values (17, 'Paul Green', '135 Chestnut St', 'NYC', '17', '2021-05-01', 9000.00, 9000.00, 'A')
insert into AMASTER values (18, 'Quinn Lee', '864 Pine St', 'LA', '18', '2021-06-01', 9500.00, 9500.00, 'A')
insert into AMASTER values (19, 'Rachel White', '753 Spruce St', 'CHI    ', '19', '2021-07-01', 10000.00, 10000.00, 'A')
insert into AMASTER values (20, 'Steve Black', '159 Maple St', 'HOU', '20', '2021-08-01', 10500.00, 10500.00, 'A')


select * from AMASTER


select * from AMASTER where BRID = 'NYC' and CBAL > 5000.00


