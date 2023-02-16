
DELIMITER $$
create procedure pro_Demo1()
begin
	select re.region_name,
		c.country_name,
		l.street_address,
		l.postal_code,
		l.city,l.state_province  
from regions re join countries c on re.region_id=c.region_id
join locations l on c.country_id=l.country_id;
end;$$
call pro_Demo1;
-- tạo một thủ tục có tên proc_Salary để xét thưởng cuối năm như sau 
-- nếu nhân viên làm trên: >= 9 thưởng lương 12tr
-- nếu làm trên 6 năm thưởng 8 tr
-- nếu làm trên 4 năm thưởng 6 tr 
-- còn lại thưởng 5 tr
DROP PROCEDURE IF EXISTS proc_Salary;
DELIMITER $$
create procedure proc_Salary()
begin
	WITH temp AS (
    SELECT first_name, 
	ROUND(DATEDIFF(CURDATE(), hire_date) / 365, 0) AS experience, 
           salary, 
           CASE 
               WHEN ROUND(DATEDIFF(CURDATE(), hire_date) / 365, 0) >= 9 THEN 12000
               WHEN ROUND(DATEDIFF(CURDATE(), hire_date) / 365, 0) > 6 THEN 8000
               WHEN ROUND(DATEDIFF(CURDATE(), hire_date) / 365, 0) > 4 THEN 6000
               ELSE 5000
           END AS bonus
    FROM employees
)
SELECT first_name, experience, salary, bonus, salary + bonus AS total_salary
FROM temp;
end;
$$
call proc_Salary()

-- tạo một pro_Search_Name(Fistname)
-- sau đó cho hiển thị toàn bộ thông tin của nhân viên đó
-- trong đó nối Fullname Firstname+ Lastname
DROP PROCEDURE IF EXISTS pro_Search_Name;
DELIMITER $$
CREATE PROCEDURE pro_Search_Name(Firstname varchar(20))
begin
	select  employee_id, concat(first_name,' ',last_name) as Fullname,
		email, phone_number, hire_date, job_id, salary, manager_id, department_id 
    from 
		employees
    where
		first_name = Firstname;
end;$$
call pro_Search_Name('David')
delimiter $$
DROP PROCEDURE IF EXISTS pro_Search_Name;
delimiter $$
-- tạo view xem 
create view viewtt
as
select e.first_name, e.last_name, l.street_address, l.city
from employees e join departments d on e.department_id=d.department_id
		join locations l on d.location_id=l.location_id;
select * from viewtt
select*from jobs

DELIMITER $$
DROP TRIGGER IF EXISTS BEFORE_INSERT_MIN_MAX_SALARY
DELIMITER $$
create trigger BEFORE_INSERT_MIN_MAX_SALARY
BEFORE INSERT ON jobs
for each row
begin
	if(new.min_salary<0 or new.max_salary<0) then
    signal sqlstate '45000'
    set message_text='The min salary or max salary value invalid';
    end if;
end$$
DELIMITER $$
DROP TRIGGER IF EXISTS BEFORE_UPDATE_MIN_MAX_SALARY
DELIMITER $$
create trigger BEFORE_UPDATE_MIN_MAX_SALARY
BEFORE UPDATE ON jobs
for each row
begin
	if(new.min_salary<0 or new.max_salary<0) then
    signal sqlstate '45000'
    set message_text='The min salary or max salary value invalid';
    end if;
end$$
DELIMITER $$
SELECT * FROM jobs;

UPDATE jobs SET min_salary = -1, max_salary = -1 WHERE (job_id = '5');

delimiter $$

set global event_scheduler = on;
show processlist;
delimiter $$
create event if not exists test_event_01
on schedule at current_timestamp
do
	insert into jobs(min_salary,max_salary)
    values(10, NOW())
delimiter $$
SELECT * FROM jobs
create event if not exists test_event_06
on schedule every 1 second
starts current_timestamp
ends current_timestamp 	+ interval 1  minute
do 
	INSERT INTO jobs (job_title, min_salary, max_salary) VALUES ('ad', '10', '10');
-- bịa ra 2 trigger
delimiter $$
drop trigger if exists trigger_21
delimiter $$
create trigger trigger_21
before insert on jobs
    for each row
    begin
		if(exists(select job_title from jobs where job_title = new.job_title))
        then
			signal sqlstate '45000'
			set message_text='The jobs_title value is avalable';
		end if;
    end$$
delimiter $$
drop trigger if exists trigger_21
delimiter $$
create trigger trigger_22
before insert on employees
    for each row
    begin
		if(DATEDIFF(CURDATE(), new.hire_date) / 365<0)
        then
			signal sqlstate '45000'
			set message_text='The hire date invalid: hire date_input cant not after current date';
        end if;
    end$$
    delimiter $$
-- bịa ra 2 event
delimiter $$
SELECT * FROM jobs;
delimiter $$
create event if not exists test_event_06
on schedule every 1 second
starts current_timestamp
ends current_timestamp 	+ interval 5  second
do 
	INSERT INTO jobs (job_title, min_salary, max_salary) VALUES ('mobile dev', '10000', '20000');
delimiter $$
create event if not exists test_event_07
on schedule every 1 second
starts current_timestamp
ends current_timestamp 	+ interval 2  second
do 
	INSERT INTO employees( `first_name`, `last_name`, `email`, `phone_number`, `hire_date`, `job_id`, `salary`, `manager_id`, `department_id`) VALUES ( 'duong', 'quang', 'trinh@gmail.com', '0333333333', '2010-09-08', '83', '11000.00', '206', '6');
delimiter $$
-- thêm dữ liệu vào employees khi đến thời điểm 16-02 lúc 6:30
create event if not exists test_event_08
on schedule at '2023-02-16 06:30:00'
do 
	INSERT INTO employees( `first_name`, `last_name`, `email`, `phone_number`, `hire_date`, `job_id`, `salary`, `manager_id`, `department_id`) VALUES ( 'duong', 'quang', 'trinh@gmail.com', '0333333333', current_date(), '83', '11000.00', '206', '6');
-- test
delimiter $$
create event if not exists test_event_09
on schedule at '2023-02-12 13:29:00'
do 
	INSERT INTO employees( `first_name`, `last_name`, `email`, `phone_number`, `hire_date`, `job_id`, `salary`, `manager_id`, `department_id`) VALUES ( 'duong', 'quang', 'trinh@gmail.com', '0333333333', current_date(), '83', '11000.00', '206', '6');
