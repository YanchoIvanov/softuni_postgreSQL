-- 1.Select Cities
SELECT
	*
FROM
	cities


-- 2.Concatenate
SELECT
	name || ' ' || state AS "Cities Information",
	area AS "Area (km2)ACTION"
FROM cities;


-- 3.Remove Duplicate Rows
SELECT DISTINCT
	name,
	area AS "Area (km2)ACTION"
FROM cities
ORDER BY name DESC;


-- 4.Limit Records
SELECT
	id AS "ID",
	first_name || ' ' || last_name AS "Full Name",
	job_title AS "Job Title"
FROM employees
ORDER BY first_name
LIMIT 50;


-- 5.Skip Rows
SELECT
	id,
	CONCAT_WS (' ', first_name, middle_name, last_name) AS "Full Name",
	hire_date AS "Hire Date"
FROM employees
ORDER BY hire_date
OFFSET 9;


-- 6.Find the Addresses
SELECT
	       id,
	       CONCAT_WS (' ', number, street) AS "Address",
	       city_id
FROM addresses
WHERE id >= 20;


-- 7.Positive Even Number
SELECT
	CONCAT_WS (' ', number, street) AS "Address",
	city_id
FROM addresses
WHERE city_id > 0
		AND
		city_id % 2 = 0
ORDER BY city_id;


-- 8.Projects within a Date Range
SELECT
	     name,
	     start_date,
	     end_date
FROM projects
WHERE start_date >= '2016-06-01 07:00:00'
		AND
		end_date < '2023-06-04 00:00:00'
ORDER BY start_date;


-- 9.Multiple Conditions
SELECT
	number,
	street
FROM addresses
WHERE number < 1000
	OR
	id BETWEEN 50 AND 100;


-- 10.Set of Values
SELECT
		employee_id,
		project_id
FROM employees_projects
WHERE employee_id IN (200, 250)
		AND
		project_id NOT IN (50, 100);


-- 11.Compare Character Values
SELECT
		name,
		start_date
FROM projects
WHERE name IN ('Mountain', 'Road', 'Touring')
LIMIT 20;


-- 12.Salary
SELECT
		first_name || ' ' || last_name AS "Full Name",
		job_title,
		salary
FROM employees
WHERE salary IN (12500, 14000, 23600, 25000)
ORDER BY salary DESC;


-- 13.Missing Value
SELECT
		id,
		first_name,
		last_name
FROM employees
WHERE middle_name IS NULL
LIMIT 3;


-- 14.INSERT Departments
INSERT INTO departments
		(department, manager_id)
VALUES
		('Finance', 3),
		('Information Services', 42),
		('Document Control', 90),
		('Quality Assurance', 274),
		('Facilities and Maintenance', 218),
		('Shipping and Receiving', 85),
		('Executive', 109);


-- 15.New Table
CREATE TABLE IF NOT EXISTS company_chart
AS
SELECT
		first_name || ' ' || last_name AS "Full Name",
		job_title AS "Job Title",
		department_id AS "Department ID",
		manager_id AS "Manager ID"
FROM employees


-- 16.Update the Project End Date
UPDATE
		projects
SET
		end_date = start_date + INTERVAL '5 months'
WHERE
		end_date IS NULL


-- 17.Award Employees with Experience
UPDATE
		employees
SET
		salary = salary + 1500,
		job_title = 'Senior' || ' ' || job_title
WHERE
		hire_date BETWEEN 'January 1, 1998' AND 'January 5, 2000'


-- 18.Delete Addresses
DELETE FROM addresses
WHERE
	city_id IN (5, 17, 20, 30);


-- 19.Create a View
CREATE VIEW view_company_chart
AS
SELECT
	"Full Name",
	"Job Title"
FROM company_chart
WHERE
	"Manager ID" = 184;


-- 20.Create a View with Multiple Tables
CREATE VIEW view_addresses
AS
SELECT
	e.first_name || ' ' || e.last_name AS "Full Name",
	e.department_id,
	a.number || ' ' || a.street AS "Address"

FROM
	employees AS e
JOIN
	addresses AS a
		ON
	e.address_id = a.id

ORDER BY "Address" ASC;


-- 21.ALTER VIEW
ALTER VIEW
	view_addresses
RENAME TO view_employee_addresses_info


-- 22.DROP VIEW
DROP VIEW view_company_chart


-- 23.UPPER
UPDATE
	projects
SET
	name = UPPER(name);


-- 24.SUBSTRING
CREATE VIEW view_initials
AS
SELECT
	SUBSTRING(first_name, 1, 2) AS initial,
	last_name
FROM employees
ORDER BY last_name;


-- 25.LIKE
SELECT
	name,
	start_date
FROM
	projects
WHERE name LIKE 'MOUNT%';

































































