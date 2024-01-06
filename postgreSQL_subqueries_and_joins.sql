-- 1.Booked for Nights
SELECT
	a.address || ' ' || a.address_2 AS apartment_address,
	b.booked_for AS nights
FROM
	apartments AS a
JOIN
	bookings AS b
USING
	(booking_id)
ORDER BY a.apartment_id


-- 2.First 10 Apartments Booked At
SELECT
	a.name,
	a.country,
	b.booked_at::date
FROM
	apartments AS a
LEFT JOIN
	bookings AS b
USING
	(booking_id)
LIMIT 10;


-- 3.First 10 Customers with Bookings
SELECT
	b.booking_id,
	b.starts_at::date,
	b.apartment_id,
	c.first_name || ' ' || c.last_name AS customer_name
FROM
	bookings AS b
RIGHT JOIN
	customers AS c
USING
	(customer_id)
ORDER BY
	customer_name ASC
LIMIT 10;


-- 4.Booking Information
SELECT
	b.booking_id,
	a.name AS apartment_owner,
	a.apartment_id,
	c.first_name || ' ' || c.last_name AS customer_name
FROM
	apartments AS a
FULL JOIN
	bookings AS b
USING
	(booking_id)
FULL JOIN
	customers AS c
USING
	(customer_id)
ORDER BY
	b.booking_id ASC, apartment_owner ASC, customer_name ASC;


-- 5.Multiplication of Information**
SELECT
	b.booking_id,
	c.first_name AS customer_name
FROM
	bookings AS b
CROSS JOIN
	customers AS c
ORDER BY
	customer_name ASC;


-- 6.Unassigned Apartments
SELECT
	b.booking_id,
	b.apartment_id,
	c.companion_full_name

FROM
	bookings AS b
JOIN
	customers AS c
ON
	b.customer_id = c.customer_id
WHERE
	apartment_id IS NULL;


-- 7.Bookings Made by Lead
SELECT
	b.apartment_id,
	b.booked_for,
	c.first_name,
	c.country
FROM
	bookings AS b
JOIN
	customers AS c
USING
	(customer_id)
WHERE
	job_type = 'Lead'


-- 8.Hahn's Bookings
SELECT
	COUNT(*)
FROM
	bookings AS b
JOIN
	customers AS c
USING
	(customer_id)
WHERE
	c.last_name = 'Hahn'


-- 9.Total Sum of Nights
SELECT
	a.name,
	SUM(b.booked_for)
FROM
	apartments AS a
JOIN
	bookings AS b
USING
	(apartment_id)
GROUP BY
	a.name
ORDER BY
	a.name ASC;


-- 10.Popular Vacation Destination
SELECT
	a.country,
	COUNT(b.booking_id) AS booking_count
FROM
	apartments AS a
JOIN
	bookings AS b
USING
	(apartment_id)
WHERE
	b.booked_at > '2021-05-18 07:52:09.904+03'
		AND
	b.booked_at < '2021-09-17 19:48:02.147+03'
GROUP BY
	a.country
ORDER BY
	booking_count DESC;


-- 11.Bulgaria's Peaks Higher than 2835 Meters
SELECT
	mc.country_code,
	m.mountain_range,
	p.peak_name,
	p.elevation
FROM
	mountains AS m
JOIN
	peaks AS p
ON
	m.id = p.mountain_id
JOIN
	mountains_countries AS mc
ON
	m.id = mc.mountain_id
WHERE
	mc.country_code = 'BG'
		AND
	p.elevation > 2835
ORDER BY
	p.elevation DESC;


-- 12.Count Mountain Ranges
SELECT
    mc.country_code,
    COUNT(m.mountain_range) AS mountain_range_count
FROM
    mountains_countries AS mc
JOIN
    mountains AS m
ON
    mc.mountain_id = m.id
WHERE
    mc.country_code IN ('US', 'RU', 'BG')
GROUP BY
    mc.country_code
ORDER BY
    mountain_range_count DESC;


-- 13.Rivers in Africa
SELECT
    c.country_name,
    r.river_name
FROM
    countries AS c
LEFT JOIN
    countries_rivers AS cr
USING
    (country_code)
LEFT JOIN
    rivers AS r
ON
    r.id = cr.river_id
WHERE
    c.continent_code = 'AF'
ORDER BY
    c.country_name ASC
LIMIT 5;


-- 14.Minimum Average Area Across Continents
SELECT
	MIN(average) AS min_average_area
FROM
	(
		SELECT
			AVG(area_in_sq_km) AS average
		FROM
			countries
		GROUP BY
			continent_code
) AS average_area;


-- 15.Countries Without Any Mountains
SELECT
    COUNT(c.country_code) AS countries_without_mountains
FROM
    countries AS c
LEFT JOIN
    mountains_countries AS mc
USING
    (country_code)
WHERE
    mountain_id IS NULL;


-- 16.Monasteries by Country **
CREATE TABLE monasteries (
    id SERIAL PRIMARY KEY,
    monastery_name VARCHAR(235),
    country_code CHAR(2)
);

INSERT INTO
    monasteries(monastery_name, country_code)
VALUES
	('Rila Monastery "St. Ivan of Rila"', 'BG'),
  	('Bachkovo Monastery "Virgin Mary"', 'BG'),
  	('Troyan Monastery "Holy Mother''s Assumption"', 'BG'),
  	('Kopan Monastery', 'NP'),
  	('Thrangu Tashi Yangtse Monastery', 'NP'),
  	('Shechen Tennyi Dargyeling Monastery', 'NP'),
  	('Benchen Monastery', 'NP'),
  	('Southern Shaolin Monastery', 'CN'),
  	('Dabei Monastery', 'CN'),
  	('Wa Sau Toi', 'CN'),
  	('Lhunshigyia Monastery', 'CN'),
  	('Rakya Monastery', 'CN'),
  	('Monasteries of Meteora', 'GR'),
  	('The Holy Monastery of Stavronikita', 'GR'),
  	('Taung Kalat Monastery', 'MM'),
  	('Pa-Auk Forest Monastery', 'MM'),
  	('Taktsang Palphug Monastery', 'BT'),
  	('Sümela Monastery', 'TR');

ALTER TABLE
    countries
ADD COLUMN
    three_rivers BOOLEAN DEFAULT FALSE;
UPDATE
    countries
SET
    three_rivers = (
    SELECT
    COUNT(*) >= 3
    FROM
    countries_rivers AS cr
	WHERE
		cr.country_code = countries.country_code
);
SELECT
    m.monastery_name AS monastery,
    c.country_name AS country
FROM
    monasteries AS m
JOIN
    countries AS c
USING
    (country_code)
WHERE
    NOT three_rivers
ORDER BY
    monastery_name ASC;


-- 17.Monasteries by Continents and Countries**
UPDATE
    countries
SET
    country_name = 'Burma'
WHERE
    country_name = 'Myanmar';

INSERT INTO
    monasteries (monastery_name, country_code)
VALUES
	('Hanga Abbey', (SELECT countries.country_code FROM Countries WHERE countries.country_name = 'Tanzania')),
   	('Myin-Tin-Daik', (SELECT countries.country_code FROM Countries WHERE countries.country_name = 'Myanmar'));

SELECT
    c.continent_name AS continent_name,
    co.country_name AS country_name,
    COUNT(m.id) AS monasteries_count
FROM
    continents AS c
LEFT JOIN
    countries AS co
USING
    (continent_code)
LEFT JOIN
    monasteries AS m
USING
    (country_code)
WHERE
    NOT three_rivers
GROUP BY
    co.country_name,
    c.continent_name
ORDER BY
    monasteries_count DESC,
    country_name ASC;


-- 18.Retrieving Information about Indexes
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename ASC,
    indexname ASC;


-- 19.Continents and Currencies
CREATE VIEW continent_currency_usage
AS
SELECT
		continent_code,
		currency_code,
		currency_usage
FROM (
	SELECT
		continent_code,
		currency_code,
		DENSE_RANK() OVER (
			PARTITION BY "continent_code"
			ORDER BY currency_usage DESC
			) AS currency_rank,
		currency_usage
	FROM (
		SELECT
			continents.continent_code,
			countries.currency_code,
			COUNT(*) AS currency_usage
		FROM
			countries
		JOIN
			continents
		USING
			(continent_code)
		GROUP BY
			continents.continent_code, countries.currency_code
		HAVING
			COUNT(*) > 1
	) AS grouped_currencies
) AS currencies_rank
WHERE
		currency_rank = 1
ORDER BY
		currency_usage DESC;


-- 20.The Highest Peak in Each Country
WITH row_number AS (
  SELECT
    c.country_name,
    p.peak_name,
    p.elevation,
    m.mountain_range,
    ROW_NUMBER() OVER (
        PARTITION BY c.country_name
        ORDER BY p.elevation DESC
        ) AS peak_rank
  FROM countries c
    LEFT JOIN mountains_countries mc on c.country_code = mc.country_code
    LEFT JOIN mountains m on mc.mountain_id = m.id
    LEFT JOIN peaks p on m.id = p.mountain_id
)
SELECT
    country_name,
    COALESCE(peak_name, '(no highest peak)') AS peak_name,
    COALESCE(elevation, 0) AS elevation,
    CASE
        WHEN peak_name IS NULL OR mountain_range IS NULL THEN '(no mountain)'
        ELSE mountain_range
    END AS mountain
FROM row_number
WHERE peak_rank = 1
ORDER BY country_name, elevation DESC;
