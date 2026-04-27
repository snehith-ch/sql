/*
    SQL Server practice setup
    Source idea: tables repeatedly referenced in SQL Final V2.0-1.pdf

    Run this whole file in SSMS/Azure Data Studio/sqlcmd.
    It creates and resets three practice databases:
      1. SQLPractice_Company
      2. SQLPractice_Retail
      3. SQLPractice_Academic

    Note: this script drops and recreates tables inside these three databases
    so you can rerun it whenever you want a clean practice dataset.
*/

IF DB_ID(N'SQLPractice_Company') IS NULL
    CREATE DATABASE SQLPractice_Company;
GO

USE SQLPractice_Company;
GO

DROP VIEW IF EXISTS dbo.vwEmployeeDepartment;
DROP TABLE IF EXISTS dbo.SalaryAudit;
DROP TABLE IF EXISTS dbo.Attendance;
DROP TABLE IF EXISTS dbo.EmployeeProjects;
DROP TABLE IF EXISTS dbo.Projects;
DROP TABLE IF EXISTS dbo.Employees;
DROP TABLE IF EXISTS dbo.Departments;
GO

CREATE TABLE dbo.Departments
(
    department_id   INT IDENTITY(1,1) CONSTRAINT PK_Departments PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL CONSTRAINT UQ_Departments_Name UNIQUE,
    location        VARCHAR(50) NOT NULL,
    budget          DECIMAL(12,2) NOT NULL CONSTRAINT CK_Departments_Budget CHECK (budget >= 0)
);

CREATE TABLE dbo.Employees
(
    employee_id      INT IDENTITY(1,1) CONSTRAINT PK_Employees PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL CONSTRAINT UQ_Employees_Email UNIQUE,
    phone            VARCHAR(20) NULL,
    department_id    INT NOT NULL,
    manager_id       INT NULL,
    job_title        VARCHAR(60) NOT NULL,
    salary           DECIMAL(10,2) NOT NULL CONSTRAINT CK_Employees_Salary CHECK (salary > 0),
    hire_date        DATE NOT NULL,
    termination_date DATE NULL,
    is_active        BIT NOT NULL CONSTRAINT DF_Employees_IsActive DEFAULT (1),
    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(department_id),
    CONSTRAINT FK_Employees_Manager
        FOREIGN KEY (manager_id) REFERENCES dbo.Employees(employee_id)
);

CREATE TABLE dbo.Projects
(
    project_id    INT IDENTITY(1,1) CONSTRAINT PK_Projects PRIMARY KEY,
    project_name  VARCHAR(80) NOT NULL,
    department_id INT NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NULL,
    status        VARCHAR(20) NOT NULL
        CONSTRAINT CK_Projects_Status CHECK (status IN ('Planned', 'Active', 'Completed', 'Paused')),
    CONSTRAINT FK_Projects_Departments
        FOREIGN KEY (department_id) REFERENCES dbo.Departments(department_id)
);

CREATE TABLE dbo.EmployeeProjects
(
    employee_id INT NOT NULL,
    project_id  INT NOT NULL,
    role_name   VARCHAR(60) NOT NULL,
    assigned_on DATE NOT NULL,
    hours_per_week INT NOT NULL CONSTRAINT CK_EmployeeProjects_Hours CHECK (hours_per_week BETWEEN 1 AND 60),
    CONSTRAINT PK_EmployeeProjects PRIMARY KEY (employee_id, project_id),
    CONSTRAINT FK_EmployeeProjects_Employees
        FOREIGN KEY (employee_id) REFERENCES dbo.Employees(employee_id),
    CONSTRAINT FK_EmployeeProjects_Projects
        FOREIGN KEY (project_id) REFERENCES dbo.Projects(project_id)
);

CREATE TABLE dbo.Attendance
(
    attendance_id   INT IDENTITY(1,1) CONSTRAINT PK_Attendance PRIMARY KEY,
    employee_id     INT NOT NULL,
    attendance_date DATE NOT NULL,
    status          VARCHAR(15) NOT NULL
        CONSTRAINT CK_Attendance_Status CHECK (status IN ('Present', 'Absent', 'Remote', 'Leave')),
    CONSTRAINT UQ_Attendance_EmployeeDate UNIQUE (employee_id, attendance_date),
    CONSTRAINT FK_Attendance_Employees
        FOREIGN KEY (employee_id) REFERENCES dbo.Employees(employee_id)
);

CREATE TABLE dbo.SalaryAudit
(
    audit_id      INT IDENTITY(1,1) CONSTRAINT PK_SalaryAudit PRIMARY KEY,
    employee_id   INT NOT NULL,
    old_salary    DECIMAL(10,2) NOT NULL,
    new_salary    DECIMAL(10,2) NOT NULL,
    change_date   DATETIME2(0) NOT NULL CONSTRAINT DF_SalaryAudit_ChangeDate DEFAULT (SYSDATETIME()),
    changed_by    VARCHAR(50) NOT NULL,
    CONSTRAINT FK_SalaryAudit_Employees
        FOREIGN KEY (employee_id) REFERENCES dbo.Employees(employee_id)
);
GO

CREATE INDEX IX_Employees_DepartmentId ON dbo.Employees(department_id);
CREATE INDEX IX_Employees_LastName ON dbo.Employees(last_name);
CREATE INDEX IX_Employees_Salary ON dbo.Employees(salary DESC);
CREATE INDEX IX_Attendance_DateStatus ON dbo.Attendance(attendance_date, status);
GO

INSERT INTO dbo.Departments (department_name, location, budget)
VALUES
    ('Executive', 'New York', 500000.00),
    ('HR', 'New York', 180000.00),
    ('Finance', 'Chicago', 260000.00),
    ('IT', 'Austin', 420000.00),
    ('Sales', 'Dallas', 390000.00),
    ('Operations', 'Seattle', 310000.00);

INSERT INTO dbo.Employees
    (first_name, last_name, email, phone, department_id, manager_id, job_title, salary, hire_date, termination_date, is_active)
VALUES
    ('Asha', 'Rao', 'asha.rao@example.com', '555-1001', 1, NULL, 'Chief Executive Officer', 165000.00, '2018-01-15', NULL, 1),
    ('Michael', 'Chen', 'michael.chen@example.com', '555-1002', 2, 1, 'HR Manager', 92000.00, '2019-03-10', NULL, 1),
    ('Priya', 'Nair', 'priya.nair@example.com', '555-1003', 3, 1, 'Finance Manager', 98000.00, '2019-06-18', NULL, 1),
    ('Daniel', 'Brooks', 'daniel.brooks@example.com', '555-1004', 4, 1, 'IT Manager', 112000.00, '2020-02-03', NULL, 1),
    ('Nina', 'Patel', 'nina.patel@example.com', '555-1005', 5, 1, 'Sales Manager', 105000.00, '2020-05-22', NULL, 1),
    ('Omar', 'Khan', 'omar.khan@example.com', '555-1006', 6, 1, 'Operations Manager', 97000.00, '2020-09-14', NULL, 1),
    ('John', 'Doe', 'john.doe@example.com', '555-1007', 3, 3, 'Accountant', 68000.00, '2021-07-01', NULL, 1),
    ('Jane', 'Smith', 'jane.smith@example.com', '555-1008', 4, 4, 'Database Developer', 87000.00, '2022-01-11', NULL, 1),
    ('Carlos', 'Gomez', 'carlos.gomez@example.com', '555-1009', 5, 5, 'Sales Representative', 61000.00, '2022-04-25', NULL, 1),
    ('Emma', 'Wilson', 'emma.wilson@example.com', '555-1010', 4, 4, 'Data Analyst', 76000.00, '2023-01-09', NULL, 1),
    ('Robert', 'Brown', 'robert.brown@example.com', '555-1011', 2, 2, 'Recruiter', 59000.00, '2023-08-17', NULL, 1),
    ('Lina', 'Garcia', 'lina.garcia@example.com', '555-1012', 6, 6, 'Logistics Coordinator', 54000.00, '2021-11-02', '2024-03-31', 0);

INSERT INTO dbo.Projects (project_name, department_id, start_date, end_date, status)
VALUES
    ('Payroll Automation', 3, '2024-01-10', NULL, 'Active'),
    ('Employee Portal', 4, '2024-02-01', NULL, 'Active'),
    ('Customer Expansion Q4', 5, '2024-07-01', '2024-12-31', 'Planned'),
    ('Warehouse Optimization', 6, '2023-09-15', '2024-05-30', 'Completed');

INSERT INTO dbo.EmployeeProjects (employee_id, project_id, role_name, assigned_on, hours_per_week)
VALUES
    (3, 1, 'Sponsor', '2024-01-10', 6),
    (7, 1, 'Finance Analyst', '2024-01-15', 18),
    (4, 2, 'Sponsor', '2024-02-01', 5),
    (8, 2, 'Developer', '2024-02-05', 28),
    (10, 2, 'Reporting Analyst', '2024-02-12', 20),
    (5, 3, 'Sponsor', '2024-07-01', 8),
    (9, 3, 'Sales Lead', '2024-07-08', 24),
    (6, 4, 'Sponsor', '2023-09-15', 6),
    (12, 4, 'Coordinator', '2023-09-20', 18);

INSERT INTO dbo.Attendance (employee_id, attendance_date, status)
VALUES
    (7, '2024-10-01', 'Present'),
    (7, '2024-10-02', 'Remote'),
    (8, '2024-10-01', 'Present'),
    (8, '2024-10-02', 'Present'),
    (9, '2024-10-01', 'Leave'),
    (9, '2024-10-02', 'Present'),
    (10, '2024-10-01', 'Remote'),
    (10, '2024-10-02', 'Absent'),
    (11, '2024-10-01', 'Present'),
    (11, '2024-10-02', 'Present');

INSERT INTO dbo.SalaryAudit (employee_id, old_salary, new_salary, change_date, changed_by)
VALUES
    (8, 82000.00, 87000.00, '2024-10-22T14:30:15', 'admin'),
    (10, 72000.00, 76000.00, '2024-10-23T09:10:00', 'admin');
GO

CREATE VIEW dbo.vwEmployeeDepartment
AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.job_title,
    e.salary,
    e.hire_date,
    e.is_active,
    d.department_name,
    d.location
FROM dbo.Employees AS e
INNER JOIN dbo.Departments AS d
    ON e.department_id = d.department_id;
GO


IF DB_ID(N'SQLPractice_Retail') IS NULL
    CREATE DATABASE SQLPractice_Retail;
GO

USE SQLPractice_Retail;
GO

DROP TABLE IF EXISTS dbo.ProductReviews;
DROP TABLE IF EXISTS dbo.InventoryTransactions;
DROP TABLE IF EXISTS dbo.Purchases;
DROP TABLE IF EXISTS dbo.Payments;
DROP TABLE IF EXISTS dbo.OrderItems;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Suppliers;
DROP TABLE IF EXISTS dbo.Categories;
DROP TABLE IF EXISTS dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
    customer_id       INT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
    customer_name     VARCHAR(80) NOT NULL,
    email             VARCHAR(120) NOT NULL CONSTRAINT UQ_Customers_Email UNIQUE,
    city              VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    last_login        DATETIME2(0) NULL
);

CREATE TABLE dbo.Categories
(
    category_id   INT IDENTITY(1,1) CONSTRAINT PK_Categories PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL CONSTRAINT UQ_Categories_Name UNIQUE
);

CREATE TABLE dbo.Suppliers
(
    supplier_id   INT IDENTITY(1,1) CONSTRAINT PK_Suppliers PRIMARY KEY,
    supplier_name VARCHAR(80) NOT NULL,
    contact_email VARCHAR(120) NULL
);

CREATE TABLE dbo.Products
(
    product_id    INT IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category_id   INT NOT NULL,
    supplier_id   INT NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL CONSTRAINT CK_Products_UnitPrice CHECK (unit_price >= 0),
    stock_quantity INT NOT NULL CONSTRAINT CK_Products_Stock CHECK (stock_quantity >= 0),
    is_active     BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1),
    last_updated  DATETIME2(0) NOT NULL CONSTRAINT DF_Products_LastUpdated DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (category_id) REFERENCES dbo.Categories(category_id),
    CONSTRAINT FK_Products_Suppliers
        FOREIGN KEY (supplier_id) REFERENCES dbo.Suppliers(supplier_id)
);

CREATE TABLE dbo.Orders
(
    order_id     INT IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY,
    customer_id  INT NOT NULL,
    order_date   DATETIME2(0) NOT NULL,
    ship_date    DATETIME2(0) NULL,
    order_status VARCHAR(20) NOT NULL
        CONSTRAINT CK_Orders_Status CHECK (order_status IN ('Pending', 'Paid', 'Shipped', 'Cancelled', 'Returned')),
    total_amount DECIMAL(12,2) NOT NULL CONSTRAINT CK_Orders_Total CHECK (total_amount >= 0),
    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
);

CREATE TABLE dbo.OrderItems
(
    order_item_id  INT IDENTITY(1,1) CONSTRAINT PK_OrderItems PRIMARY KEY,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL CONSTRAINT CK_OrderItems_Quantity CHECK (quantity > 0),
    price_per_unit DECIMAL(10,2) NOT NULL CONSTRAINT CK_OrderItems_Price CHECK (price_per_unit >= 0),
    discount_amount DECIMAL(10,2) NOT NULL CONSTRAINT DF_OrderItems_Discount DEFAULT (0),
    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);

CREATE TABLE dbo.Payments
(
    payment_id     INT IDENTITY(1,1) CONSTRAINT PK_Payments PRIMARY KEY,
    order_id       INT NOT NULL,
    payment_date   DATETIME2(0) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount         DECIMAL(12,2) NOT NULL CONSTRAINT CK_Payments_Amount CHECK (amount > 0),
    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id)
);

CREATE TABLE dbo.Purchases
(
    purchase_id     INT IDENTITY(1,1) CONSTRAINT PK_Purchases PRIMARY KEY,
    customer_id     INT NOT NULL,
    purchase_date   DATETIME2(0) NOT NULL,
    purchase_amount DECIMAL(12,2) NOT NULL CONSTRAINT CK_Purchases_Amount CHECK (purchase_amount > 0),
    CONSTRAINT FK_Purchases_Customers
        FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
);

CREATE TABLE dbo.InventoryTransactions
(
    transaction_id   INT IDENTITY(1,1) CONSTRAINT PK_InventoryTransactions PRIMARY KEY,
    product_id       INT NOT NULL,
    transaction_date DATETIME2(0) NOT NULL,
    change_quantity  INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL
        CONSTRAINT CK_InventoryTransactions_Type CHECK (transaction_type IN ('Purchase', 'Sale', 'Return', 'Adjustment')),
    notes            VARCHAR(150) NULL,
    CONSTRAINT FK_InventoryTransactions_Products
        FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
);

CREATE TABLE dbo.ProductReviews
(
    review_id    INT IDENTITY(1,1) CONSTRAINT PK_ProductReviews PRIMARY KEY,
    product_id   INT NOT NULL,
    customer_id  INT NOT NULL,
    rating       TINYINT NOT NULL CONSTRAINT CK_ProductReviews_Rating CHECK (rating BETWEEN 1 AND 5),
    review_text  VARCHAR(300) NULL,
    review_date  DATE NOT NULL,
    CONSTRAINT FK_ProductReviews_Products
        FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id),
    CONSTRAINT FK_ProductReviews_Customers
        FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
);
GO

CREATE INDEX IX_Orders_CustomerDate ON dbo.Orders(customer_id, order_date DESC);
CREATE INDEX IX_OrderItems_ProductId ON dbo.OrderItems(product_id);
CREATE INDEX IX_Products_CategoryName ON dbo.Products(category_id, product_name);
CREATE INDEX IX_Purchases_CustomerDate ON dbo.Purchases(customer_id, purchase_date DESC);
GO

INSERT INTO dbo.Customers (customer_name, email, city, registration_date, last_login)
VALUES
    ('Anika Sharma', 'anika.sharma@example.com', 'Bengaluru', '2022-05-14', '2024-10-08T18:15:00'),
    ('Rahul Mehta', 'rahul.mehta@example.com', 'Hyderabad', '2022-11-03', '2024-10-10T09:05:00'),
    ('Sara Johnson', 'sara.johnson@example.com', 'Chicago', '2023-02-19', '2024-09-30T21:40:00'),
    ('David Lee', 'david.lee@example.com', 'Seattle', '2023-06-28', NULL),
    ('Fatima Ali', 'fatima.ali@example.com', 'Dallas', '2024-01-12', '2024-10-09T13:25:00'),
    ('Grace Kim', 'grace.kim@example.com', 'Austin', '2024-03-22', '2024-10-11T08:00:00');

INSERT INTO dbo.Categories (category_name)
VALUES
    ('Stationery'),
    ('Electronics'),
    ('Books'),
    ('Home Office');

INSERT INTO dbo.Suppliers (supplier_name, contact_email)
VALUES
    ('Northwind Wholesale', 'sales@northwind.example.com'),
    ('TechSource', 'orders@techsource.example.com'),
    ('Readers Hub', 'support@readershub.example.com'),
    ('OfficePro', 'hello@officepro.example.com');

INSERT INTO dbo.Products (product_name, category_id, supplier_id, unit_price, stock_quantity, is_active, last_updated)
VALUES
    ('Gel Pen Pack', 1, 1, 12.50, 180, 1, '2024-10-01T09:00:00'),
    ('Notebook A5', 1, 1, 4.75, 250, 1, '2024-10-01T09:00:00'),
    ('Wireless Mouse', 2, 2, 24.99, 65, 1, '2024-10-02T10:30:00'),
    ('Mechanical Keyboard', 2, 2, 89.00, 22, 1, '2024-10-02T10:30:00'),
    ('SQL Basics Book', 3, 3, 31.50, 40, 1, '2024-10-03T11:15:00'),
    ('Desk Lamp', 4, 4, 45.00, 35, 1, '2024-10-03T12:00:00'),
    ('Monitor Stand', 4, 4, 38.00, 18, 1, '2024-10-04T15:20:00'),
    ('USB-C Hub', 2, 2, 54.00, 12, 1, '2024-10-04T16:10:00');

INSERT INTO dbo.Orders (customer_id, order_date, ship_date, order_status, total_amount)
VALUES
    (1, '2024-01-10T10:15:00', '2024-01-12T09:00:00', 'Shipped', 59.50),
    (2, '2024-01-15T11:40:00', '2024-01-17T16:00:00', 'Shipped', 199.46),
    (1, '2024-03-05T15:20:00', '2024-03-07T10:00:00', 'Shipped', 89.00),
    (3, '2024-04-18T08:30:00', '2024-04-20T13:45:00', 'Shipped', 76.50),
    (5, '2024-06-01T19:05:00', NULL, 'Cancelled', 45.00),
    (4, '2024-08-11T14:10:00', '2024-08-13T11:30:00', 'Shipped', 116.50),
    (2, '2024-10-05T12:00:00', '2024-10-07T12:00:00', 'Paid', 197.46),
    (6, '2024-10-10T17:45:00', NULL, 'Pending', 108.00);

INSERT INTO dbo.OrderItems (order_id, product_id, quantity, price_per_unit, discount_amount)
VALUES
    (1, 1, 2, 12.50, 0.00),
    (1, 2, 1, 4.75, 0.00),
    (1, 5, 1, 31.50, 1.75),
    (2, 3, 4, 24.99, 0.00),
    (2, 6, 2, 45.00, 0.00),
    (2, 2, 2, 4.75, 0.00),
    (3, 4, 1, 89.00, 0.00),
    (4, 5, 1, 31.50, 0.00),
    (4, 6, 1, 45.00, 0.00),
    (5, 6, 1, 45.00, 0.00),
    (6, 7, 1, 38.00, 0.00),
    (6, 5, 1, 31.50, 0.00),
    (6, 1, 4, 12.50, 3.00),
    (7, 3, 4, 24.99, 0.00),
    (7, 2, 10, 4.75, 0.00),
    (7, 1, 4, 12.50, 0.00),
    (8, 8, 2, 54.00, 0.00);

INSERT INTO dbo.Payments (order_id, payment_date, payment_method, amount)
VALUES
    (1, '2024-01-10T10:20:00', 'Card', 59.50),
    (2, '2024-01-15T11:45:00', 'UPI', 199.46),
    (3, '2024-03-05T15:25:00', 'Card', 89.00),
    (4, '2024-04-18T08:35:00', 'Wallet', 76.50),
    (6, '2024-08-11T14:15:00', 'Card', 116.50),
    (7, '2024-10-05T12:05:00', 'UPI', 197.46);

INSERT INTO dbo.Purchases (customer_id, purchase_date, purchase_amount)
VALUES
    (1, '2024-10-05T09:30:00', 200.00),
    (1, '2024-09-10T11:20:00', 120.00),
    (2, '2024-10-10T16:00:00', 250.00),
    (2, '2023-12-20T10:00:00', 90.00),
    (3, '2024-04-18T08:30:00', 76.50),
    (6, '2024-10-10T17:45:00', 108.00);

INSERT INTO dbo.InventoryTransactions (product_id, transaction_date, change_quantity, transaction_type, notes)
VALUES
    (1, '2024-10-01T08:00:00', 100, 'Purchase', 'Restock'),
    (1, '2024-10-05T12:00:00', -4, 'Sale', 'Order 7'),
    (3, '2024-10-05T12:00:00', -4, 'Sale', 'Order 7'),
    (8, '2024-10-10T17:45:00', -2, 'Sale', 'Order 8'),
    (8, '2024-10-12T09:00:00', 15, 'Purchase', 'Supplier delivery'),
    (7, '2024-10-13T10:00:00', -2, 'Adjustment', 'Damaged items');

INSERT INTO dbo.ProductReviews (product_id, customer_id, rating, review_text, review_date)
VALUES
    (3, 2, 5, 'Comfortable and reliable.', '2024-01-20'),
    (5, 1, 4, 'Good for SQL revision.', '2024-03-10'),
    (6, 3, 5, 'Bright lamp for study desk.', '2024-04-25'),
    (7, 4, 3, 'Useful but slightly heavy.', '2024-08-20'),
    (1, 6, 4, 'Smooth writing pens.', '2024-10-12');
GO


IF DB_ID(N'SQLPractice_Academic') IS NULL
    CREATE DATABASE SQLPractice_Academic;
GO

USE SQLPractice_Academic;
GO

DROP TABLE IF EXISTS dbo.StudentAttendance;
DROP TABLE IF EXISTS dbo.Grades;
DROP TABLE IF EXISTS dbo.CoursePrerequisites;
DROP TABLE IF EXISTS dbo.Enrollments;
DROP TABLE IF EXISTS dbo.Courses;
DROP TABLE IF EXISTS dbo.Instructors;
DROP TABLE IF EXISTS dbo.Students;
GO

CREATE TABLE dbo.Students
(
    student_id        INT IDENTITY(1,1) CONSTRAINT PK_Students PRIMARY KEY,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(120) NOT NULL CONSTRAINT UQ_Students_Email UNIQUE,
    date_of_birth     DATE NOT NULL,
    registration_date DATE NOT NULL
);

CREATE TABLE dbo.Instructors
(
    instructor_id   INT IDENTITY(1,1) CONSTRAINT PK_Instructors PRIMARY KEY,
    instructor_name VARCHAR(80) NOT NULL,
    department      VARCHAR(60) NOT NULL,
    email           VARCHAR(120) NOT NULL CONSTRAINT UQ_Instructors_Email UNIQUE
);

CREATE TABLE dbo.Courses
(
    course_id     INT IDENTITY(1,1) CONSTRAINT PK_Courses PRIMARY KEY,
    course_name   VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,
    credits       TINYINT NOT NULL CONSTRAINT CK_Courses_Credits CHECK (credits BETWEEN 1 AND 6),
    course_level  VARCHAR(20) NOT NULL
        CONSTRAINT CK_Courses_Level CHECK (course_level IN ('Beginner', 'Intermediate', 'Advanced')),
    CONSTRAINT FK_Courses_Instructors
        FOREIGN KEY (instructor_id) REFERENCES dbo.Instructors(instructor_id)
);

CREATE TABLE dbo.Enrollments
(
    enrollment_id   INT IDENTITY(1,1) CONSTRAINT PK_Enrollments PRIMARY KEY,
    student_id      INT NOT NULL,
    course_id       INT NOT NULL,
    enrollment_date DATE NOT NULL,
    status          VARCHAR(20) NOT NULL
        CONSTRAINT CK_Enrollments_Status CHECK (status IN ('Active', 'Completed', 'Dropped')),
    CONSTRAINT UQ_Enrollments_StudentCourse UNIQUE (student_id, course_id),
    CONSTRAINT FK_Enrollments_Students
        FOREIGN KEY (student_id) REFERENCES dbo.Students(student_id),
    CONSTRAINT FK_Enrollments_Courses
        FOREIGN KEY (course_id) REFERENCES dbo.Courses(course_id)
);

CREATE TABLE dbo.CoursePrerequisites
(
    course_id              INT NOT NULL,
    prerequisite_course_id INT NOT NULL,
    CONSTRAINT PK_CoursePrerequisites PRIMARY KEY (course_id, prerequisite_course_id),
    CONSTRAINT FK_CoursePrerequisites_Course
        FOREIGN KEY (course_id) REFERENCES dbo.Courses(course_id),
    CONSTRAINT FK_CoursePrerequisites_Prerequisite
        FOREIGN KEY (prerequisite_course_id) REFERENCES dbo.Courses(course_id),
    CONSTRAINT CK_CoursePrerequisites_NotSelf CHECK (course_id <> prerequisite_course_id)
);

CREATE TABLE dbo.Grades
(
    grade_id      INT IDENTITY(1,1) CONSTRAINT PK_Grades PRIMARY KEY,
    enrollment_id INT NOT NULL CONSTRAINT UQ_Grades_Enrollment UNIQUE,
    score         DECIMAL(5,2) NOT NULL CONSTRAINT CK_Grades_Score CHECK (score BETWEEN 0 AND 100),
    grade_letter  CHAR(2) NOT NULL,
    graded_on     DATE NOT NULL,
    CONSTRAINT FK_Grades_Enrollments
        FOREIGN KEY (enrollment_id) REFERENCES dbo.Enrollments(enrollment_id)
);

CREATE TABLE dbo.StudentAttendance
(
    attendance_id   INT IDENTITY(1,1) CONSTRAINT PK_StudentAttendance PRIMARY KEY,
    enrollment_id   INT NOT NULL,
    attendance_date DATE NOT NULL,
    status          VARCHAR(15) NOT NULL
        CONSTRAINT CK_StudentAttendance_Status CHECK (status IN ('Present', 'Absent', 'Late')),
    CONSTRAINT UQ_StudentAttendance_EnrollmentDate UNIQUE (enrollment_id, attendance_date),
    CONSTRAINT FK_StudentAttendance_Enrollments
        FOREIGN KEY (enrollment_id) REFERENCES dbo.Enrollments(enrollment_id)
);
GO

CREATE INDEX IX_Courses_NameInstructor ON dbo.Courses(course_name, instructor_id);
CREATE INDEX IX_Enrollments_StudentCourse ON dbo.Enrollments(student_id, course_id);
CREATE INDEX IX_Grades_Score ON dbo.Grades(score DESC);
GO

INSERT INTO dbo.Students (first_name, last_name, email, date_of_birth, registration_date)
VALUES
    ('Isha', 'Verma', 'isha.verma@example.com', '2002-04-12', '2023-07-01'),
    ('Arjun', 'Kapoor', 'arjun.kapoor@example.com', '2001-09-05', '2023-07-01'),
    ('Meera', 'Iyer', 'meera.iyer@example.com', '2003-01-20', '2023-08-15'),
    ('Kabir', 'Malhotra', 'kabir.malhotra@example.com', '2002-11-30', '2024-01-10'),
    ('Sofia', 'Martinez', 'sofia.martinez@example.com', '2001-06-22', '2024-01-10'),
    ('Ethan', 'Clark', 'ethan.clark@example.com', '2000-12-02', '2024-02-01');

INSERT INTO dbo.Instructors (instructor_name, department, email)
VALUES
    ('Dr. Kavita Menon', 'Computer Science', 'kavita.menon@example.com'),
    ('Prof. Alan Wright', 'Data Analytics', 'alan.wright@example.com'),
    ('Dr. Maria Lopez', 'Business', 'maria.lopez@example.com'),
    ('Prof. Neel Shah', 'Computer Science', 'neel.shah@example.com');

INSERT INTO dbo.Courses (course_name, instructor_id, credits, course_level)
VALUES
    ('SQL Basics', 1, 3, 'Beginner'),
    ('Database Design', 4, 4, 'Intermediate'),
    ('Data Warehousing', 2, 4, 'Advanced'),
    ('Business Analytics', 3, 3, 'Intermediate'),
    ('Query Optimization', 4, 3, 'Advanced');

INSERT INTO dbo.Enrollments (student_id, course_id, enrollment_date, status)
VALUES
    (1, 1, '2024-01-15', 'Completed'),
    (1, 2, '2024-02-01', 'Active'),
    (2, 1, '2024-01-15', 'Completed'),
    (2, 3, '2024-02-05', 'Active'),
    (3, 1, '2024-01-20', 'Completed'),
    (3, 4, '2024-03-01', 'Active'),
    (4, 2, '2024-03-10', 'Active'),
    (5, 4, '2024-03-01', 'Dropped'),
    (6, 5, '2024-04-15', 'Active');

INSERT INTO dbo.CoursePrerequisites (course_id, prerequisite_course_id)
VALUES
    (2, 1),
    (3, 2),
    (5, 2);

INSERT INTO dbo.Grades (enrollment_id, score, grade_letter, graded_on)
VALUES
    (1, 92.50, 'A', '2024-05-15'),
    (3, 78.00, 'B', '2024-05-15'),
    (5, 88.25, 'A', '2024-05-15'),
    (8, 61.00, 'C', '2024-04-10');

INSERT INTO dbo.StudentAttendance (enrollment_id, attendance_date, status)
VALUES
    (2, '2024-10-01', 'Present'),
    (2, '2024-10-02', 'Late'),
    (4, '2024-10-01', 'Present'),
    (4, '2024-10-02', 'Absent'),
    (6, '2024-10-01', 'Present'),
    (7, '2024-10-01', 'Present'),
    (9, '2024-10-01', 'Late'),
    (9, '2024-10-02', 'Present');
GO

PRINT 'SQL practice databases created and seeded successfully.';
GO
