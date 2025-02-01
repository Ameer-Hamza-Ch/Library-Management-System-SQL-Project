Here’s the properly formatted Markdown version of your **Library Management System using SQL** project for your GitHub `README.md` file:

---

# Library Management System using SQL

## Project Overview

- **Project Title:** Library Management System  
- **Level:** Intermediate  
- **Database:** `LMS`  

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

---

## Objectives

1. **Set up the Library Management System Database:** Create and populate the database with tables for branches, employees, members, books, issued status, and return status.  
2. **CRUD Operations:** Perform Create, Read, Update, and Delete operations on the data.  
3. **CTAS (Create Table As Select):** Utilize CTAS to create new tables based on query results.  
4. **Advanced SQL Queries:** Develop complex queries to analyze and retrieve specific data.  

---

## Project Structure

### 1. Database Setup

#### ERD
The database schema includes tables for `books`, `branch`, `employee`, `issued_status`, `members`, and `return_status`.

#### Database Creation
Created a database named `LMS`.

```sql
CREATE DATABASE LMS;
USE LMS;
```

#### Table Creation
Created tables with relevant columns and relationships.

```sql
-- Creating Tables
CREATE TABLE books (
    isbn VARCHAR(20),
    book_title VARCHAR(75),
    category VARCHAR(30),
    rental_price FLOAT,
    status CHAR(3),
    author VARCHAR(50),
    publisher VARCHAR(70),
    CONSTRAINT PRIMARY KEY(isbn)
);

CREATE TABLE branch (
    branch_id VARCHAR(5),
    manager_id VARCHAR(5),
    branch_address VARCHAR(50),
    contact_no VARCHAR(30),
    CONSTRAINT PRIMARY KEY(branch_id)
);

DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
    emp_id VARCHAR(10),
    emp_name VARCHAR(50),
    position VARCHAR(30),
    salary INT,
    branch_id VARCHAR(10),
    CONSTRAINT PRIMARY KEY(emp_id)
);

CREATE TABLE issued_status (
    issued_id VARCHAR(10),
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(50),
    issued_date DATE,
    issued_book_isbn VARCHAR(20),
    issued_emp_id VARCHAR(10),
    CONSTRAINT PRIMARY KEY(issued_id)
);

CREATE TABLE members (
    member_id VARCHAR(10),
    member_name VARCHAR(50),
    member_address VARCHAR(70),
    reg_date DATE,
    CONSTRAINT PRIMARY KEY(member_id)
);

CREATE TABLE return_status (
    return_id VARCHAR(10),
    issued_id VARCHAR(10),
    return_book_name VARCHAR(75),
    return_date DATE,
    return_book_isbn VARCHAR(20),
    CONSTRAINT PRIMARY KEY(return_id)
);

-- Adding Foreign Keys
ALTER TABLE return_status
ADD CONSTRAINT fk_constraint
FOREIGN KEY(issued_id) REFERENCES issued_status(issued_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issuedmem_id
FOREIGN KEY(issued_member_id) REFERENCES members(member_id);

ALTER TABLE employee
ADD CONSTRAINT fk_branch_id
FOREIGN KEY(branch_id) REFERENCES branch(branch_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_isbn
FOREIGN KEY(issued_book_isbn) REFERENCES books(isbn);

ALTER TABLE issued_status
MODIFY COLUMN issued_book_name VARCHAR(100);
```

---

### 2. CRUD Operations

#### Create: Insert a New Book Record
Inserted sample records into the `books` table.

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```

#### Update: Update an Existing Member's Address
Updated records in the `members` table.

```sql
UPDATE members
SET member_address='133 Oak St'
WHERE member_id='C118';
```

#### Delete: Remove a Record from the Issued Status Table
Deleted a record from the `issued_status` table.

```sql
DELETE FROM issued_status
WHERE issued_id='IS121';
```

#### Read: Retrieve All Books Issued by a Specific Employee
Retrieved data from the `issued_status` table.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id='E103';
```

#### Read: List Members Who Have Issued More Than Two Books
Used `GROUP BY` to find members who have issued more than two books.

```sql
SELECT issued_member_id, COUNT(issued_member_id)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 2;
```

---

### 3. CTAS (Create Table As Select)

#### Task 6: Create Summary Tables
Used CTAS to generate new tables based on query results.

```sql
CREATE TABLE issued_book_count AS
SELECT b.book_title, b.isbn, COUNT(ist.issued_book_isbn)
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.isbn;
```

---

### 4. Data Analysis & Findings

#### Task 7: Retrieve Number of Books in All Categories
```sql
SELECT category, COUNT(category)
FROM books
GROUP BY category
ORDER BY COUNT(category) DESC;
```

#### Task 8: Retrieve All Books in a Specific Category (e.g., Fantasy)
```sql
SELECT book_title, category
FROM books
WHERE category='Fantasy';
```

#### Task 9: Find Total Rental Price per Category
```sql
SELECT category, SUM(rental_price)
FROM books
GROUP BY category;
```

#### Task 10: Find Total Rental Income by Category
```sql
SELECT b.category, SUM(b.rental_price) AS Rental_income
FROM books AS b
JOIN issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;
```

#### Task 11: List Members Who Registered in the Last 180 Days
```sql
SELECT *
FROM members
WHERE reg_date BETWEEN DATE_SUB('2022-01-05', INTERVAL 180 DAY) AND '2022-01-05';
```

#### Task 12: Create a Table of Books with Rental Price Above a Certain Threshold (e.g., 7)
```sql
CREATE TABLE books_of_price_above_7 AS
SELECT * FROM books
WHERE rental_price > 7;
```

#### Task 13: List Employees with Their Branch Manager's Name and Branch Details
```sql
SELECT e.emp_id, e.emp_name, e.position, e.salary, e.branch_id, b.manager_id, b.branch_address, b.contact_no, e1.emp_name AS manager
FROM employee AS e
JOIN branch AS b
ON e.branch_id = b.branch_id
JOIN employee AS e1
ON e1.emp_id = b.manager_id;
```

#### Task 14: Retrieve the List of Books Not Yet Returned
```sql
SELECT i.issued_id, r.return_id, i.issued_member_id, issued_book_name, i.issued_date, i.issued_book_isbn, issued_emp_id
FROM issued_status AS i
LEFT JOIN return_status AS r
ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
```

#### Task 15: Branch Performance Report
```sql
CREATE TABLE branch_report AS
SELECT br.branch_id, br.manager_id, COUNT(i.issued_emp_id) AS total_issued_books, COUNT(r.issued_id) AS total_books_returned, SUM(b.rental_price) AS total_rental_income
FROM issued_status AS i
JOIN employee AS e
ON i.issued_emp_id = e.emp_id
JOIN branch AS br
ON br.branch_id = e.branch_id
LEFT JOIN return_status AS r
ON r.issued_id = i.issued_id
JOIN books AS b
ON b.isbn = i.issued_book_isbn
GROUP BY br.branch_id
ORDER BY br.branch_id;

SELECT * FROM branch_report;
```

#### Task 16: CTAS - Create a Table of Active Members
```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATE_SUB('2024-04-25', INTERVAL 1 MONTH)
);

SELECT * FROM active_members;
```

#### Task 17: Find Employees with the Most Book Issues Processed
```sql
SELECT e.emp_name, b.*, COUNT(i.issued_book_name) AS Book_issues_processed
FROM issued_status AS i
JOIN employee AS e
ON i.issued_emp_id = e.emp_id
JOIN branch AS b
ON b.branch_id = e.branch_id
GROUP BY issued_emp_id
ORDER BY COUNT(issued_book_name) DESC
LIMIT 3;
```

#### Task 18: CTAS - Identify Overdue Books and Calculate Fines
```sql
CREATE TABLE fines_per_book AS
SELECT i.issued_id, i.issued_member_id, i.issued_date, m.member_name, m.member_address, i.issued_book_isbn, i.issued_book_name, DATEDIFF('2024-04-25', i.issued_date) AS overdue
FROM issued_status AS i
JOIN members AS m
ON i.issued_member_id = m.member_id
WHERE DATEDIFF('2024-04-25', i.issued_date) > 30;

ALTER TABLE fines_per_book
ADD COLUMN fine DOUBLE;

SET SQL_SAFE_UPDATES = 0;

UPDATE fines_per_book
SET fine = overdue * 0.5
WHERE fine IS NULL;
```

---

### Stored Procedures

#### Task 19: Update Book Status on Return
```sql
DELIMITER $$
CREATE PROCEDURE update_return_book_status(IN p_return_id VARCHAR(10), IN p_issued_id VARCHAR(10))
BEGIN
    DECLARE v_isbn VARCHAR(90);
    DECLARE v_book_name VARCHAR(100);

    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE());

    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status='yes'
    WHERE isbn = v_isbn;

    SELECT CONCAT('Thanks for returning book: ', v_isbn) AS Message;
END $$
DELIMITER ;

CALL update_return_book_status('RS138', 'IS135');
```

#### Task 20: Manage Book Status Based on Issuance
```sql
DELIMITER $$
CREATE PROCEDURE update_book_status(IN p_issued_id VARCHAR(20), IN p_issued_member_id VARCHAR(20), IN p_issued_book_isbn VARCHAR(30), IN p_issued_emp_id VARCHAR(10))
BEGIN
    DECLARE v_status VARCHAR(10);

    SELECT status INTO v_status FROM books
    WHERE p_issued_book_isbn = isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE(), p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status='no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS Message;
    ELSE
        SELECT CONCAT('Sorry to inform you the book you have requested is unavailable book_isbn: ', p_issued_book_isbn) AS Message;
    END IF;
END $$
DELIMITER ;

CALL update_book_status('IS141', 'C108', '978-0-553-29698-2', 'E104');
```

---

## Reports

1. **Database Schema:** Detailed table structures and relationships.  
2. **Data Analysis:** Insights into book categories, employee salaries, member registration trends, and issued books.  
3. **Summary Reports:** Aggregated data on high-demand books and employee performance.  

---

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

---

## How to Use

1. **Clone the Repository:** Clone this repository to your local machine.  
   ```bash
   git clone <https://github.com/Ameer-Hamza-Ch/Library-Management-System-SQL-Project.git>
   ```
2. **Set Up the Database:** Execute the SQL scripts in the `LMS.sql` file to create the database.  
3. **Create Tables & Insert Data:** Use the SQL `insertion_queries.sql` file to make and insert data into tables.  
4. **Run the Queries:** Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.  
5. **Explore and Modify:** Customize the queries as needed to explore different aspects of the data or answer additional questions.  

---

**Author:** Ameer Hamza Ch  

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:


Thank you for your interest in this project!
