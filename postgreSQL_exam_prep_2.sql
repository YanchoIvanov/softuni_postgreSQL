-- Section 1. Data Definition Language (DDL) - (30 pts)

CREATE TABLE addresses(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

CREATE TABLE categories(
	id SERIAL PRIMARY KEY,
	name VARCHAR(10) NOT NULL
);

CREATE TABLE clients(
	id SERIAL PRIMARY KEY,
	full_name VARCHAR(50) NOT NULL,
	phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE drivers(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(30) NOT NULL,
	last_name VARCHAR(30) NOT NULL,
	age INT NOT NULL,
	rating NUMERIC(3, 2) DEFAULT 5.5,

	CONSTRAINT ck_drivers_age
		CHECK (age > 0)
);

CREATE TABLE cars(
	id SERIAL PRIMARY KEY,
	make VARCHAR(20) NOT NULL,
	model VARCHAR(20),
	year INT NOT NULL DEFAULT 0,
	mileage INT DEFAULT 0,
	condition CHAR(1) NOT NULL,
	category_id INT NOT NULL,

	CONSTRAINT ck_cars_year
		CHECK (year > 0),

	CONSTRAINT ck_cars_mileage
		CHECK (mileage > 0),

	CONSTRAINT fk_cars_categories
		FOREIGN KEY (category_id)
		REFERENCES categories(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE courses(
	id SERIAL PRIMARY KEY,
	from_address_id INT NOT NULL,
	start TIMESTAMP NOT NULL,
	bill NUMERIC(10, 2) DEFAULT 10,
	car_id INT NOT NULL,
	client_id INT NOT NULL,

	CONSTRAINT ck_courses_bill
	CHECK(bill > 0),

	CONSTRAINT fk_courses_addresses
		FOREIGN KEY (from_address_id)
		REFERENCES addresses(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,

	CONSTRAINT fk_courses_cars
		FOREIGN KEY (car_id)
		REFERENCES cars(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,

	CONSTRAINT fk_courses_clients
		FOREIGN KEY (client_id)
		REFERENCES clients(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE cars_drivers(
	car_id INT NOT NULL,
	driver_id INT NOT NULL,

	CONSTRAINT fk_cars_drivers_cars
		FOREIGN KEY (car_id)
		REFERENCES cars(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,

	CONSTRAINT fk_cars_drivers_drivers
		FOREIGN KEY (driver_id)
		REFERENCES drivers(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);


-- Section 2. Data Manipulation Language (DML) - (10 pts)
INSERT INTO
	clients (full_name, phone_number)
SELECT
	first_name || ' ' || last_name,
	'(088) 9999' || id * 2
FROM
	drivers
WHERE
	id >= 10
	AND
	id <= 20;


UPDATE
	cars
SET
	condition = 'C'
WHERE
	(mileage >= 800000 OR mileage IS NULL)
	AND
	year <= 2010
	AND
	make <> 'Mercedes-Benz'


DELETE FROM
	clients
WHERE
	id NOT IN (SELECT client_id FROM courses)
		AND
	LENGTH(full_name) > 3


SELECT
	make,
	model,
	condition
FROM
	cars
ORDER BY
	id


SELECT
	d.first_name,
	d.last_name,
	c.make,
	c.model,
	c.mileage
FROM
	drivers AS d
JOIN
	cars_drivers AS cd
ON
	d.id = cd.driver_id
JOIN
	cars AS c
ON
	c.id = cd.car_id
WHERE
	c.mileage IS NOT NULL
ORDER BY
	c.mileage DESC, d.first_name ASC;


SELECT
	ca.id AS car_id,
	ca.make,
	ca.mileage,
	COUNT(co.id) AS count_of_courses,
	ROUND(AVG(co.bill), 2) AS average_bill
FROM
	cars AS ca
LEFT JOIN
	courses AS co
ON
	ca.id = co.car_id
GROUP BY
	ca.id
HAVING
	COUNT(co.id) <> 2
ORDER BY
	count_of_courses DESC, ca.id ASC;


SELECT
	cl.full_name,
	COUNT(co.car_id) AS count_of_cars,
	SUM(co.bill) AS total_sum
FROM
	clients AS cl
JOIN
	courses AS co
ON
	cl.id = co.client_id
WHERE
	SUBSTR(cl.full_name, 2, 1) = 'a'
GROUP BY
	cl.id
HAVING
	COUNT(car_id) > 1
ORDER BY
	cl.full_name;


SELECT
	a.name AS address,
	CASE
	WHEN EXTRACT(HOUR FROM cou.start) BETWEEN 6 AND 20 THEN 'Day'
	ELSE 'Night'
	END AS day_time,
	cou.bill,
	cl.full_name,
	car.make,
	car.model,
	cat.name AS category_name
FROM
	clients AS cl
JOIN
	courses AS cou
ON
	cl.id = cou.client_id
JOIN
	cars AS car
ON
	cou.car_id = car.id
JOIN
	categories AS cat
ON
	car.category_id = cat.id
JOIN
	addresses AS a
ON
	cou.from_address_id = a.id


-- Section 4. Programmability - (20 pt)
CREATE OR REPLACE FUNCTION fn_courses_by_client(
	phone_num VARCHAR(20)
)
RETURNS INT
AS
$$
BEGIN
	RETURN(
			SELECT
				COUNT(*)
			FROM
				clients AS cl
			JOIN
				courses AS c
			ON
				cl.id = c.client_id
			WHERE
				cl.phone_number = phone_num
	);
END;
$$
LANGUAGE plpgsql;


CREATE TABLE search_results (
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);


CREATE OR REPLACE PROCEDURE sp_courses_by_address(
	IN address_name VARCHAR(100)
)
AS
$$
BEGIN
	TRUNCATE search_results;

	INSERT INTO
		search_results(address_name, full_name, level_of_bill, make, condition, category_name)
	SELECT
		a.name,
		cl.full_name,
		CASE
		WHEN cou.bill <= 20 THEN 'Low'
		WHEN cou.bill <= 30 THEN 'Medium'
		ELSE 'High'
		END AS level_of_bill,
		car.make,
		car.condition,
		cat.name AS category_name
	FROM
		addresses AS a
	JOIN
		courses AS cou
	ON
		cou.from_address_id = a.id
	JOIN
		cars AS car
	ON
		car.id = cou.car_id
	JOIN
		categories AS cat
	ON
		cat.id = car.category_id
	JOIN
		clients AS cl
	ON
		cl.id = cou.client_id
	WHERE
		a.name = address_name
	ORDER BY
		car.make, cl.full_name;
END;
$$
LANGUAGE plpgsql;
