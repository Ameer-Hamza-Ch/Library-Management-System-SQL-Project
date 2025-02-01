use LMS;

-- Create a new book record
insert into books(isbn, book_title, category, rental_price ,status, author, publisher) 
Values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Update record
update members
set member_address='133 Oak St'
where member_id='C118';

-- Delete record
Delete from issued_status
where issued_id='IS121';

select * from issued_status
where issued_id='IS121';

select * from issued_status
where issued_emp_id='E103';

select * from members;

select issued_member_id, count(issued_member_id) 
from issued_status
group by issued_member_id
having count(issued_member_id) > 2;

-- CTAS
select * from issued_status;

-- Each books along with it's issue count 
select isbn, count(isbn) from books
group by isbn;

select issued_book_isbn, count(issued_book_isbn)
from issued_status
group by issued_book_isbn;

select * from issued_status;

drop table if exists issued_book_count;

create table issued_book_count As
select b.book_title, b.isbn, count(ist.issued_book_isbn)
from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
group by b.isbn;

select * from issued_book_count;

-- Retrieve number of books in all categories
select category, count(category)
from books
group by category
order by count(category) desc;

-- Retrieve all books in a specific category
select book_title, category
from books
where category='Fantasy';

-- Total rental price per category
select category, sum(rental_price)
from books
group by category;

-- Total rental income per category
select b.category, sum(b.rental_price), count(b.category)
from books as b
Join issued_status as ist
on b.isbn=ist.issued_book_isbn
group by b.category;

-- Display members registered from '2022-02-05'to 180 days back.
SELECT *
FROM members
WHERE reg_date BETWEEN DATE_SUB('2022-01-05', INTERVAL 180 DAY) AND '2022-01-05';

-- List Employees with Their Branch Manager's Name and their branch details
select e.emp_id, e.emp_name, e.position, e.salary, e.branch_id, b.manager_id, b.branch_address, b.contact_no, e1.emp_name as manager 
from employee as e
join branch as b
on e.branch_id= b.branch_id
join employee as e1
on e1.emp_id=b.manager_id;

create table books_of_price_above_7 As
select * from books
where rental_price > 7;

-- Create a Table of Books with Rental Price Above a Certain Threshold
select * from books_of_price_above_7;

-- Retrieve the List of Books Not Yet Returned
select * 
from (select i.issued_id, r.return_id, i.issued_member_id, issued_book_name, i.issued_date, i.issued_book_isbn, issued_emp_id 
from issued_status as i
left join return_status as r
on i.issued_id = r.issued_id) AS L1
where L1.return_id is null;

-- OR
select i.issued_id, r.return_id, i.issued_member_id, issued_book_name, i.issued_date, i.issued_book_isbn, issued_emp_id 
from issued_status as i
left join return_status as r
on i.issued_id = r.issued_id
where r.return_id is null;

-- Identify Members with Overdue Books 
select i.issued_member_id,m.member_name, i.issued_book_name, i.issued_date, i.issued_book_isbn, 
(datediff('2024-04-25', i.issued_date)) as over_dues_days 
from issued_status as i
join members as m
on i.issued_member_id= m.member_id
left join return_status as r
on i.issued_id = r.issued_id
where 
(r.return_id is null) AND  ((datediff('2024-04-25', i.issued_date))> 30);

-- 
create table branch_report As
select br.branch_id, br.manager_id, count(i.issued_emp_id) as total_issued_books, count(r.issued_id) as total_books_returned, sum(b.rental_price) as total_rental_income
from issued_status as i
join employee as e
on i.issued_emp_id=e.emp_id
join branch as br
on br.branch_id= e.branch_id
left join return_status as r
on r.issued_id=i.issued_id
join books as b
on b.isbn= i.issued_book_isbn
group by br.branch_id
order by br.branch_id; 

select * from branch_report;

-- 
create table active_members As
(select * from members where
member_id IN
(SELECT 
DISTINCT issued_member_id   
FROM issued_status
WHERE 
issued_date >= date_sub('2024-04-25', interval 1 Month))
);

select * from active_members;

--
select e.emp_name, b.*, count(i.issued_book_name) as Book_issues_processed from issued_status as i
join employee as e
on i.issued_emp_id= e.emp_id
join branch as b
on b.branch_id= e.branch_id
group by issued_emp_id
order by count(issued_book_name) desc
limit 3;

-- Storing Procedures
DELIMITER $$
create procedure update_book_status(IN p_issued_id varchar(20), IN p_issued_member_id varchar(20), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))

Begin

    declare v_status varchar(10);
    
	select status into v_status from books
    where p_issued_book_isbn=isbn;
    
    if v_status='yes' then
		
        insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        values
        (p_issued_id, p_issued_member_id, current_date(), p_issued_book_isbn, p_issued_emp_id);
        
        update books
        set status='no'
        where isbn=p_issued_book_isbn;
        
        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS Message;
        
   else
        SELECT CONCAT('Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn) AS Message;
    END IF;
    
End $$
delimiter ;

CALL update_book_status('IS141', 'C108', '978-0-553-29698-2', 'E104');
CALL update_book_status('IS142', 'C108', '978-0-375-41398-8', 'E104');


delimiter $$
create procedure update_return_book_status(IN p_return_id varchar(10), p_issued_id varchar(10))
begin
     
    declare v_isbn varchar(90);
    declare v_book_name varchar(100);
        
	insert into return_status(return_id, issued_id, return_date)
    values
    (p_return_id, p_issued_id, current_date());
    
    SELECT 
	issued_book_isbn, issued_book_name
	INTO
	v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;
    
    update books
    set status='yes'
    where isbn= v_isbn;
    
    SELECT CONCAT('Thanks for returning book: ', v_isbn) AS Message;
    
End $$
Delimiter ;

select * from books;

CALL update_return_book_status('RS138', 'IS135');

-- calling function 
CALL update_return_book_status('RS148', 'IS140');

-- Checkin for update in the table
select * from issued_status;

-- Creating table as select
create table fines_per_book As
(select i.issued_id, i.issued_member_id, i.issued_date, m.member_name, m.member_address, i.issued_book_isbn, i.issued_book_name, datediff('2024-04-25', i.issued_date) as overdue from issued_status as i  
join members as m
on i.issued_member_id= m.member_id
where datediff('2024-04-25', i.issued_date) > 30);

select * from fines_per_book;

-- Altering table to include a new column for fines
alter table fines_per_book
add column fine double;

-- To update the Sql safe mode, to allow update in the record
SET SQL_SAFE_UPDATES = 0;

-- Calculating and updating fine
update fines_per_book
set fine= overdue * 0.5
where fine is null;
