-- Section 1. Data Definition Language (DDL) - (30 pts)
CREATE TABLE owners(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	phone_number VARCHAR(50) NOT NULL,
	address VARCHAR(50)
);

CREATE TABLE animal_types(
	id SERIAL PRIMARY KEY,
	animal_type VARCHAR(50) NOT NULL
);

CREATE TABLE cages(
	id SERIAL PRIMARY KEY,
	animal_type_id INT NOT NULL
);

CREATE TABLE animals(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	birthdate DATE NOT NULL,
	owner_id INT,
	animal_type_id INT NOT NULL
);

CREATE TABLE volunteers_departments(
	id SERIAL PRIMARY KEY,
	department_name VARCHAR(30) NOT NULL
);

CREATE TABLE volunteers(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	phone_number VARCHAR(15) NOT NULL,
	address VARCHAR(50),
	animal_id INT,
	department_id INT NOT NULL
);

CREATE TABLE animals_cages(
	cage_id INT NOT NULL,
	animal_id INT NOT NULL
);

ALTER TABLE cages
ADD CONSTRAINT fk_cages_animal_types
	FOREIGN KEY (animal_type_id)
		REFERENCES animal_types(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
;

ALTER TABLE animals
ADD CONSTRAINT fk_animals_owners
	FOREIGN KEY (owner_id)
		REFERENCES owners(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
ADD CONSTRAINT fk_animals_animal_types
	FOREIGN KEY (animal_type_id)
		REFERENCES animal_types(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
;

ALTER TABLE volunteers
ADD CONSTRAINT fk_volunteers_animals
	FOREIGN KEY (animal_id)
		REFERENCES animals(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
ADD CONSTRAINT fk_volunteers_volunteers_departments
	FOREIGN KEY (department_id)
		REFERENCES volunteers_departments(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
;

ALTER TABLE animals_cages
ADD CONSTRAINT fk_animals_cages_cages
	FOREIGN KEY (cage_id)
		REFERENCES cages(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
ADD CONSTRAINT fk_animals_cages_animals
	FOREIGN KEY (animal_id)
		REFERENCES animals(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
;


-- Section 2. Data Manipulation Language (DML) - (10 pts)
INSERT INTO
	volunteers(name, phone_number, address, animal_id, department_id)
VALUES
	('Anita Kostova', '0896365412',	'Sofia, 5 Rosa str.', 15, 1),
	('Dimitur Stoev', '0877564223',	NULL,	42,	4),
    ('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9,	7),
    ('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
    ('Boryana Mileva', '0888112233', NULL, 31, 5)
;

INSERT INTO
	animals(name, birthdate, owner_id, animal_type_id)
VALUES
	('Giraffe',	'2018-09-21', 21, 1),
	('Harpy Eagle',	'2015-04-17', 15, 3),
	('Hamadryas Baboon', '2017-11-02', NULL, 1),
	('Tuatara',	'2021-06-30', 2, 4)
;


UPDATE
	animals
SET
	owner_id = (SELECT id FROM owners WHERE name = 'Kaloqn Stoqnov')
WHERE
	owner_id IS NULL


DELETE FROM volunteers_departments
WHERE id = (SELECT id FROM volunteers_departments WHERE department_name = 'Education program assistant')


-- Section 3. Querying - (40 pts)
SELECT
	name,
	phone_number,
	address,
	animal_id,
	department_id
FROM
	volunteers
ORDER BY
	name ASC, animal_id ASC, department_id ASC;


SELECT
	a.name,
	at.animal_type,
	to_char(a.birthdate, 'DD.MM.YYYY')
FROM
	animals AS a
JOIN
	animal_types AS at
ON
	a.animal_type_id = at.id
ORDER BY
	a.name ASC;


SELECT
	o.name AS owner,
	COUNT(a.owner_id) AS count_of_animals
FROM
	owners AS o
JOIN
	animals AS a
ON
	o.id = a.owner_id
GROUP BY
	o.name
ORDER BY
	count_of_animals DESC, owner ASC
LIMIT
	5


SELECT
	o.name || ' - ' || a.name AS "Owners - Animals",
	o.phone_number AS "Phone Number",
	ac.cage_id AS "Cage ID"
FROM
	owners AS o
JOIN
	animals AS a
ON
	o.id = a.owner_id
JOIN
	animals_cages AS ac
ON
	ac.animal_id = a.id
JOIN
	animal_types AS at
ON
	at.id = a.animal_type_id
WHERE at.animal_type = 'Mammals'
ORDER BY
	o.name ASC, a.name DESC;


SELECT
	v.name AS volunteers,
	v.phone_number,
	SUBSTRING(TRIM(REPLACE(v.address, 'Sofia', '')), 3) AS address
FROM
	volunteers AS v
JOIN
	volunteers_departments AS vd
ON
	v.department_id = vd.id
WHERE
	v.address LIKE '%Sofia%'
	AND
	vd.department_name = 'Education program assistant'
ORDER BY
	v.name ASC;


SELECT
	a.name AS animal,
	TO_CHAR(a.birthdate, 'YYYY') AS birth_year,
	at.animal_type
FROM
	animals AS a
LEFT JOIN
	owners AS o
ON
	a.owner_id = o.id
JOIN
	animal_types AS at
ON
	a.animal_type_id = at.id
WHERE
	at.animal_type <> 'Birds'
	AND
	a.owner_id IS NULL
	AND
	AGE('01/01/2022', a.birthdate) < '5 years'
ORDER BY
	a.name;


-- Section 4. Programmability - (20 pts)
CREATE OR REPLACE FUNCTION fn_get_volunteers_count_from_department(
	searched_volunteers_department VARCHAR(30)
)
RETURNS INT
AS
$$
BEGIN
	RETURN(
			SELECT
				COUNT(*)
			FROM
				volunteers AS v
			JOIN
				volunteers_departments AS vd
			ON
				v.department_id = vd.id
			WHERE
				vd.department_name = searched_volunteers_department
	);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(
	IN animal_name VARCHAR(30),
	OUT o_name VARCHAR(50)
)
AS
$$
BEGIN
	SELECT
		o.name
	FROM
		owners AS o
	LEFT JOIN
		animals AS a
	ON
		o.id = a.owner_id
	WHERE
		a.name = animal_name
	INTO o_name;
	IF o_name IS NULL THEN o_name := 'For adoption';
	END IF;
	RETURN;
END;
$$
LANGUAGE plpgsql;

