-- Data Cleaning Project

-- 1) Create copy of raw data called nc_gym_data2.

SELECT *
FROM nc_gym_data;

CREATE TABLE nc_gym_data2 
LIKE nc_gym_data;

INSERT INTO nc_gym_data2
SELECT *
FROM nc_gym_data;

-- 2) Merge column 2 extra data into column 1 to make later separation easier.

-- 2a) Removed location text from column2 to later combine with column 1.
--     Location data already in column1 so assumed that was the correct location.

UPDATE nc_gym_data2
SET column2 = REPLACE(column2, LEFT(column2, LOCATE(';', column2)), '')
WHERE column2 != '';

-- 2b) Combined column1 and column2 data using concat at rows where the data was originally split into two columns.

UPDATE nc_gym_data2
SET column1 = CONCAT(column1, ';', column2)
WHERE column2 != '';

ALTER TABLE nc_gym_data2
DROP column2;

-- 3) Separate data into columns using ';' as delimiter and storing data into a new table called 'nc_gym_data3'.

-- 3a) Query to view split data first.

SELECT SUBSTRING_INDEX(column1, ';', 1) AS open_gym_start,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 2), ';', -1) AS open_gym_end,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 3), ';', -1) AS total_females,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 4), ';', -1) AS total_males,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 5), ';', -1) AS total_non_residents,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 6), ';', -1) AS total_residents,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 7), ';', -1) AS total,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 8), ';', -1) AS facility_title,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 9), ';', -1) AS LOCATION,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 10), ';', -1) AS address,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 11), ';', -1) AS province,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 12), ';', -1) AS postal_code,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 13), ';', -1) AS pass_type,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 14), ';', -1) AS community_center,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 15), ';', -1) AS open_gym,
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 16), ';', -1) AS group_type
FROM nc_gym_data2;

-- 3b) Created new table to bring in substring index data from step 3a.
--     Total columns created as varchar to temporarily match total string data types of nc_gym_data2 table. Will modify later.

CREATE TABLE nc_gym_data3 
(
	open_gym_start VARCHAR(250),
	open_gym_end VARCHAR(250),
	total_females VARCHAR(250),
	total_males VARCHAR(250),
	total_non_residents VARCHAR(250),
	total_residents VARCHAR(250),
	total VARCHAR(250),
	facility_title VARCHAR(250),
	location VARCHAR(250),
	address VARCHAR(250),
	province VARCHAR(250),
	postal_code VARCHAR(250),
	pass_type VARCHAR(250),
	community_center VARCHAR(250),
	open_gym VARCHAR(250),
	group_type VARCHAR(250)
);

SELECT *
FROM nc_gym_data3;

-- 3c) Inserted split data from nc_gym_data2 into newly formed nc_gym_data3 table.

INSERT INTO nc_gym_data3
SELECT SUBSTRING_INDEX(column1, ';', 1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 2), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 3), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 4), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 5), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 6), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 7), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 8), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 9), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 10), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 11), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 12), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 13), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 14), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 15), ';', -1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(column1, ';', 16), ';', -1)
FROM nc_gym_data2;

DELETE
FROM nc_gym_data3
WHERE open_gym_start = 'open_gym_start';

-- 4) Update/remove missing values in total columns.

-- 4a) Subquery to view where male and female totals do not equal the total.
--     Will update blanks where possible to match the provided total.

SELECT *
FROM
  (SELECT total_females,
          total_males,
          total_females + total_males AS session_total,
          total,
          CASE
              WHEN total_females + total_males != total THEN 'error'
              ELSE 'does equal total'
          END AS num_check
   FROM nc_gym_data3) AS subq
WHERE num_check = 'error';

-- 4b) Added two columns: female/male check and resident/nonresident check, for determining if their totals add to the total column.

ALTER TABLE nc_gym_data3 
ADD female_male_check VARCHAR(20),
ADD nonres_res_check VARCHAR(20);

UPDATE nc_gym_data3
SET female_male_check = CASE
                            WHEN total_females + total_males != total THEN 'error'
                            ELSE 'equals'
                        END,
    nonres_res_check = CASE
			    WHEN total_non_residents + total_residents != total THEN 'error'
			    ELSE 'equals'
		        END;

-- 4c) Queries to view totals where the total females/males and total residents/nonresidents do not equal the stored value in the total column.

SELECT total_females,
       total_males,
       total,
       female_male_check
FROM nc_gym_data3
WHERE female_male_check = 'error';

SELECT total_non_residents,
       total_residents,
       total,
       nonres_res_check
FROM nc_gym_data3
WHERE nonres_res_check = 'error';

-- 4d) Updated values where possible to fill in missing total males values.

UPDATE nc_gym_data3
SET total_males = total - total_females
WHERE total_females != ''
  AND total_males = ''
  AND female_male_check = 'error';

-- 4e) Removed remaining values entered incorrectly into the data that do not equal the total.

DELETE
FROM nc_gym_data3
WHERE female_male_check = 'error'
  OR nonres_res_check = 'error';

-- 4f) Fill in remaining blank values in total columns with 0 for data consistency.
--     Modify total cols to int. Drop equal check columns.

UPDATE nc_gym_data3
SET total_females = CASE WHEN total_females = '' THEN 0 ELSE total_females END,
	total_males = CASE WHEN total_males = '' THEN 0 ELSE total_males END,
	total_non_residents =CASE WHEN total_non_residents = '' THEN 0 ELSE total_non_residents END,
	total_residents =CASE WHEN total_residents = '' THEN 0 ELSE total_residents END;

ALTER TABLE nc_gym_data3 
MODIFY total_females INT, 
MODIFY total_males INT, 
MODIFY total_non_residents INT, 
MODIFY total_residents INT, 
MODIFY total INT;

ALTER TABLE nc_gym_data3
DROP COLUMN female_male_check,
DROP COLUMN nonres_res_check;

-- 5) Update/remove remaining blank values after total columns.

-- 5a) Queries to view blank values in remaining columns after total columns.

SELECT *
FROM nc_gym_data3
WHERE facility_title = ''
  OR address = ''
  OR province = ''
  OR postal_code = ''
  OR pass_type = ''
  OR community_center = ''
  OR open_gym = '';

-- 5b) Queries to determine which facilities offer badminton sessions. Bond Park only one. Assumed blank value for badminton above relates to Bond Park.
--     Updated missing row values shown in query above to match other data from bond park for badminton pass type.

SELECT DISTINCT facility_title, location
FROM nc_gym_data3
WHERE pass_type = 'Open Gym - Badminton';

SELECT DISTINCT address,
                province,
                postal_code,
                pass_type,
                community_center,
                open_gym
FROM nc_gym_data3
WHERE facility_title = 'Bond Park Community Center';

UPDATE nc_gym_data3
SET address = '150 Metro Park',
    province = 'NC',
    postal_code = '27513',
    community_center = 'BPCC',
    facility_title = 'Bond Park Community Center'
WHERE facility_title = ''
  AND pass_type = 'Open Gym - Badminton';

-- 5c) Query to determine which facilities offer open pickleball gym sessions. All do.

SELECT DISTINCT facility_title
FROM nc_gym_data3
WHERE pass_type = 'Open Gym - Pickleball';

-- 5d) Query to determine which facilities have auxiliary in their location. Just Middle Creek.

SELECT DISTINCT facility_title, location
FROM nc_gym_data3
WHERE LOCATION LIKE '%auxiliary%';

-- 5e) Unable to fill in blank values with Middle Creek data for auxiliary due to other community centers also offering pickleball sessions.
--     Removed the remaining blank values shown in 5a.
--     Dropped irrelevent data in the group_type column.

DELETE
FROM nc_gym_data3
WHERE facility_title = '';

ALTER TABLE nc_gym_data3
DROP COLUMN group_type;

-- 6) Remove possible duplicates.

-- 6a) Use CTE to check for duplicates. None.

WITH duplicates AS
  (SELECT *,
          row_number() OVER (PARTITION BY open_gym_start,
                                          open_gym_end,
                                          total_females,
                                          total_males,
                                          total_non_residents,
                                          total_residents,
                                          total,
                                          facility_title,
                                          LOCATION,
                                          address,
                                          province,
                                          postal_code,
                                          pass_type,
                                          community_center,
                                          open_gym) AS row_num
   FROM nc_gym_data3)
SELECT *
FROM duplicates
WHERE row_num = 2;

-- 7) Standardize and restructure open gym session start and end times. Convert UTC to EDT. Add time lapse data.

SELECT open_gym_start, open_gym_end
FROM nc_gym_data3;

-- 7a) Remove string before converting UTC to EDT.

UPDATE nc_gym_data3
SET open_gym_start = trim(TRAILING ':00+00:00' FROM open_gym_start),
    open_gym_end = trim(TRAILING ':00+00:00' FROM open_gym_end);

UPDATE nc_gym_data3
SET open_gym_start = REPLACE(open_gym_start, 'T', ' '),
    open_gym_end = REPLACE(open_gym_end, 'T', ' ');

-- 7b) Update datatype of start and end columns to datetime.

ALTER TABLE nc_gym_data3 
MODIFY open_gym_start DATETIME,
MODIFY open_gym_end DATETIME;

-- 7c) Convert UTC to EDT.

UPDATE nc_gym_data3
SET open_gym_start = CONVERT_TZ(open_gym_start, '+00:00', '-04:00'),
    open_gym_end = CONVERT_TZ(open_gym_end, '+00:00', '-04:00');

-- 7d) Queries to verify if start and end dates are all on the same day to consolidate into one column.
--     Two entries have different start and end dates. Will leave start and end timestamps as is.

SELECT *
FROM
  (SELECT SUBSTRING_INDEX(open_gym_start, ' ', 1) AS start_date,
          SUBSTRING_INDEX(open_gym_end, ' ', 1) AS end_date
   FROM nc_gym_data3) AS subq
WHERE start_date != end_date;

SELECT *
FROM nc_gym_data3
WHERE open_gym_start LIKE '2019-12-14%'
	AND open_gym_end LIKE '2019-12-15%';

SELECT *
FROM nc_gym_data3
WHERE open_gym_start LIKE '2014-02-08%'
  AND open_gym_end LIKE '2014-02-09%';

-- 7e) Added column calculating the time lapse between start and end times.

ALTER TABLE nc_gym_data3 
ADD session_length TIME AS (TIMEDIFF(open_gym_end, open_gym_start)) AFTER open_gym_end;
