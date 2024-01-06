-- 1.River Info
CREATE OR REPLACE VIEW
	view_river_info
AS
SELECT
	CONCAT('The river', ' ', river_name, ' ', 'flows into the', ' ', outflow, ' ', 'and is', ' ', length, ' ', 'kilometers long.')
AS "River Information"
FROM rivers
ORDER BY river_name;


-- 2.Concatenate Geography Data
CREATE OR REPLACE VIEW
	view_continents_countries_currencies_details
AS
SELECT
	CONCAT(con.continent_name, ': ', con.continent_code) AS "Continent Details",
	CONCAT_WS(' - ', cou.country_name, cou.capital, cou.area_in_sq_km, 'km2') AS "Country Information",
	CONCAT(cur.description,' (', cur.currency_code, ')') AS "Currencies"
FROM
	continents AS con,
	countries AS cou,
	currencies AS cur
WHERE
	con.continent_code = cou.continent_code
	AND
	cou.currency_code = cur.currency_code
ORDER BY
	"Country Information" ASC,
	"Currencies" ASC


-- 3.Capital Code
ALTER TABLE
	countries
ADD COLUMN
	capital_code CHAR(2);
UPDATE
	countries
SET
	capital_code = SUBSTRING(capital FROM 1 FOR 2)


-- 4.(Descr)iption
SELECT
	SUBSTRING(description FROM 5) as "substring"
FROM
	currencies


-- 5.Substring River Length
SELECT
	(REGEXP_MATCHES("River Information", '([0-9]{1,4})'))[1] AS river_lenght
FROM
	view_river_info


-- 6.Replace A
SELECT
	REPLACE(mountain_range, 'a', '@') AS replace_a,
	REPLACE(mountain_range, 'A', '$') AS replace_A
FROM
	mountains


-- 7.Translate
SELECT
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou') AS translated_name
FROM
	countries;


-- 8.LEADING
SELECT
	continent_name,
	TRIM(LEADING FROM continent_name) AS trim
FROM
	continents;


-- 9.TRAILING
SELECT
	continent_name,
	TRIM(TRAILING FROM continent_name) AS trim
FROM
	continents;


-- 10.LTRIM & RTRIM
SELECT
	LTRIM(peak_name, 'M') AS "Left Trim",
	RTRIM(peak_name, 'm') AS "Right Trim"
FROM


-- 11.Character Length and Bits
SELECT
	CONCAT(m.mountain_range, ' ', p.peak_name) AS "Mountain Information",
	CHAR_LENGTH(CONCAT(m.mountain_range, ' ', p.peak_name)) AS "Characters Length",
	BIT_LENGTH(CONCAT(m.mountain_range, ' ', p.peak_name)) AS "Bits of a String"
FROM
	mountains AS m,
	peaks AS p
WHERE
	m."id" = p.mountain_id;


-- 12.Length of a Number
SELECT
	population,
	LENGTH(CAST(population AS VARCHAR)) AS length
FROM
	countries;


-- 13.Positive and Negative LEFT
-- 14.Positive and Negative RIGHT
-- 15.Update iso_code
UPDATE
	countries
SET
	iso_code = UPPER((LEFT(country_name, 3)))
WHERE
	iso_code IS NULL;


-- 16.REVERSE country_code
UPDATE
	countries
SET
	country_code = LOWER((REVERSE(country_code)))


-- 17. Elevation --->> Peak Name
SELECT
	CONCAT(elevation, ' ', REPEAT('-', 3), REPEAT('>', 2), ' ', peak_name) AS "Elevation --->> Peak Name"
FROM
	peaks
WHERE
	elevation >= 4884;


-- 18.Arithmetical Operators
CREATE TABLE
	bookings_calculation
AS
SELECT
	booked_for,
	CAST(booked_for * 50 AS NUMERIC) AS multiplication,
	CAST(booked_for % 50 AS NUMERIC) AS modulo
FROM
	bookings
WHERE
	apartment_id = 93;


-- 19.ROUND vs TRUNC
SELECT
	latitude,
	ROUND(latitude, 2) AS round,
	TRUNC(latitude, 2) AS trunc
FROM
	apartments;


-- 20.Absolute Value
SELECT
	longitude,
	ABS(longitude) AS abs
FROM
	apartments;


-- 21.Billing Day**
ALTER TABLE
	bookings
ADD COLUMN
	billing_day TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

SELECT
	TO_CHAR(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS') AS "Billing Day"
FROM
	bookings;


-- 22.EXTRACT Booked At
SELECT
	EXTRACT(YEAR FROM booked_at) AS "YEAR",
	EXTRACT(MONTH FROM booked_at) AS "MONTH",
	EXTRACT(DAY FROM booked_at) AS "DAY",
	EXTRACT(HOUR FROM booked_at AT TIME ZONE 'UTC') AS "HOUR",
	EXTRACT(MINUTE FROM booked_at) AS "MINUTE",
	CEILING(EXTRACT(SECOND FROM booked_at)) AS "SECOND"
FROM
	bookings;


-- 23. Early Birds**
SELECT
	user_id,
	AGE(starts_at, booked_at) AS "Early Birds"
FROM
	bookings
WHERE
	starts_at - booked_at >= '10 MONTHS';


-- 24.Match or Not
SELECT
	companion_full_name,
	email
FROM
	users
WHERE
	companion_full_name ILIKE '%aNd%'
	AND
	email NOT LIKE '%@gmail';


-- 25. * COUNT by Initial
SELECT
	LEFT(first_name, 2) AS initials,
	COUNT('initials') AS user_count
FROM
	users
GROUP BY
	initials
ORDER BY
	user_count DESC,
	initials ASC;


-- 26. * SUM
SELECT
	SUM(booked_for) AS total_value
FROM
	bookings
WHERE
	apartment_id = 90;


-- 27. * Average Value
SELECT
	AVG(multiplication) AS average_value
FROM
	bookings_calculation











































