 ----------CLEAN 2016---------------------------------------------------Changing data types, dropping unecessary columns, editing column names, dropping unecessary rows

SELECT * 
FROM H1B2016

--view data type of columns in table
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'H1B2016'


--change data type of prevailing_wage column to money
ALTER TABLE H1B2016
ALTER COLUMN PREVAILING_WAGE money;

--edit some values in prevailing wage
UPDATE H1B2016
SET PREVAILING_WAGE_2016 = 1230860.80
WHERE PREVAILING_WAGE_2016 = 12308608.00

UPDATE H1B2016
SET PREVAILING_WAGE_2016 = 99939.84
WHERE PREVAILING_WAGE_2016 = 9993984.00

--MAKE A NEW COLUMN AND ADD THE YEAR VALUE FROM THE YEAR COLUMN TO IT AND THEN DROP YEAR COLUMN AND RENAME OTHER COLUMN
ALTER TABLE H1B2016
ADD [JUSTYEAR] INT, YEAR_2016 INT, STATE VARCHAR(50), EMPLOYER_STATE_2016 VARCHAR(50), latitude DECIMAL(18,3), longtitude DECIMAL(18,3);

--update the justyear column to contain the values in year. 
UPDATE H1B2016
SET [JUSTYEAR] = YEAR([YEAR]);
--drop year column
ALTER TABLE h1b2016
DROP COLUMN [year];
--rename justyear to year
EXEC sp_rename 'H1B2016.[JUSTYEAR]', 'YEAR', 'COLUMN';


--change data type of lon column to decimal
--update the new column with the converted values from the old column
UPDATE H1B2016
SET longtitude = CONVERT(DECIMAL(18,3), lon);
-- Finally, drop the old column and rename the new column to the original column name
ALTER TABLE H1B2016
DROP COLUMN lon;
--figure out why i cant convert varchar to numeric. because it had some values that needed to be updated
SELECT *
FROM H1B2016
WHERE ISNUMERIC(lon) = 0
--update 'na' with null
UPDATE H1B2016
SET lon = NULL
WHERE lon = 'NA'

--for the lat and lon columns
CREATE FUNCTION ConvertToDecimal (@value VARCHAR(50))
RETURNS DECIMAL(18,3)
AS
BEGIN
    DECLARE @result DECIMAL(18,3)
    IF ISNUMERIC(@value) = 1
        SET @result = CONVERT(DECIMAL(18,3), @value)
    ELSE
        SET @result = NULL
    RETURN @result
END


--edit the datatype of the lon column
-- Update the new column with the converted values from the old column using the function
UPDATE H1B2016
SET latitude = dbo.ConvertToDecimal(lat);
-- Drop the old column and rename the new column to the original column name
ALTER TABLE H1B2016
DROP COLUMN lat;

---drop columns---Not needed in data analysis. 
ALTER TABLE H1B2016
DROP COLUMN FULL_TIME_POSITION, longtitude, latitude;

RenameAllColumns 'H1B2016', 'JOB_TITLE', '_2016';
RenameAllColumns 'H1B2016', 'PREVAILING_WAGE', '_2016';
RenameAllColumns 'H1B2016', 'WORKSITE', '_2016';
RenameAllColumns 'H1B2016', 'YEAR', '_2016';

--rename column [year] to year_2016 using database hop
UPDATE H1B2016
SET YEAR_2016 = "[YEAR]"

ALTER TABLE h1b2016
DROP COLUMN "[YEAR]";

--get the state out of the worksite column
UPDATE H1B2016
SET STATE = SUBSTRING(WORKSITE_2016, CHARINDEX(',', WORKSITE_2016) + 2, LEN(WORKSITE_2016))


--convert the state to abbreviations
UPDATE H1B2016
SET EMPLOYER_STATE_2016 = CASE 
    WHEN state = 'Alabama' THEN 'AL'
    WHEN state = 'Alaska' THEN 'AK'
    WHEN state = 'Arizona' THEN 'AZ'
    WHEN state = 'Arkansas' THEN 'AR'
    WHEN state = 'California' THEN 'CA'
    WHEN state = 'Colorado' THEN 'CO'
    WHEN state = 'Connecticut' THEN 'CT'
    WHEN state = 'Delaware' THEN 'DE'
    WHEN state = 'Florida' THEN 'FL'
    WHEN state = 'Georgia' THEN 'GA'
    WHEN state = 'Hawaii' THEN 'HI'
    WHEN state = 'Idaho' THEN 'ID'
    WHEN state = 'Illinois' THEN 'IL'
    WHEN state = 'Indiana' THEN 'IN'
    WHEN state = 'Iowa' THEN 'IA'
    WHEN state = 'Kansas' THEN 'KS'
    WHEN state = 'Kentucky' THEN 'KY'
    WHEN state = 'Louisiana' THEN 'LA'
    WHEN state = 'Maine' THEN 'ME'
    WHEN state = 'Maryland' THEN 'MD'
    WHEN state = 'Massachusetts' THEN 'MA'
    WHEN state = 'Michigan' THEN 'MI'
    WHEN state = 'Minnesota' THEN 'MN'
    WHEN state = 'Mississippi' THEN 'MS'
    WHEN state = 'Missouri' THEN 'MO'
    WHEN state = 'Montana' THEN 'MT'
    WHEN state = 'Nebraska' THEN 'NE'
    WHEN state = 'Nevada' THEN 'NV'
    WHEN state = 'New Hampshire' THEN 'NH'
    WHEN state = 'New Jersey' THEN 'NJ'
    WHEN state = 'New Mexico' THEN 'NM'
    WHEN state = 'New York' THEN 'NY'
    WHEN state = 'North Carolina' THEN 'NC'
    WHEN state = 'North Dakota' THEN 'ND'
    WHEN state = 'Ohio' THEN 'OH'
    WHEN state = 'Oklahoma' THEN 'OK'
    WHEN state = 'Oregon' THEN 'OR'
    WHEN state = 'Pennsylvania' THEN 'PA'
    WHEN state = 'Rhode Island' THEN 'RI'
    WHEN state = 'South Carolina' THEN 'SC'
    WHEN state = 'South Dakota' THEN 'SD'
    WHEN state = 'Tennessee' THEN 'TN'
    WHEN state = 'Texas' THEN 'TX'
    WHEN state = 'Utah' THEN 'UT'
    WHEN state = 'Vermont' THEN 'VT'
    WHEN state = 'Virginia' THEN 'VA'
    WHEN state = 'Washington' THEN 'WA'
    WHEN state = 'West Virginia' THEN 'WV'
    WHEN state = 'Wisconsin' THEN 'WI'
    WHEN state = 'Wyoming' THEN 'WY'
    ELSE NULL
END;

--drop unecessary columns
ALTER TABLE h1b2016
DROP COLUMN STATE, WORKSITE_2016;

--Remove duplicates by averaging prevailing wage
UPDATE H1B2016
SET PREVAILING_WAGE_2016 = (
  SELECT AVG(PREVAILING_WAGE_2016)
  FROM H1B2016
  WHERE EMPLOYER_NAME_2016 = 'SOAPROJECTS, INC'
    AND SOC_NAME_2016 = 'ACCOUNTANTS AND AUDITORS'
    AND JOB_TITLE_2016 = 'SR. MANAGER, SOX & INTERNAL AUDIT GROUP'
    AND YEAR_2016 = 2015
    AND EMPLOYER_STATE_2016 = 'CA'
)
WHERE EMPLOYER_NAME_2016 = 'SOAPROJECTS, INC'
  AND SOC_NAME_2016 = 'ACCOUNTANTS AND AUDITORS'
  AND JOB_TITLE_2016 = 'SR. MANAGER, SOX & INTERNAL AUDIT GROUP'
  AND YEAR_2016 = 2015
  AND EMPLOYER_STATE_2016 = 'CA';

--Delete duplicate row
DELETE TOP(1) FROM H1B2016
WHERE 
    CASE_STATUS_2016 = 'CERTIFIED' AND
    EMPLOYER_NAME_2016 = 'SOAPROJECTS, INC' AND
    SOC_NAME_2016 = 'ACCOUNTANTS AND AUDITORS' AND
    JOB_TITLE_2016 = 'SR. MANAGER, SOX & INTERNAL AUDIT GROUP' AND
    PREVAILING_WAGE_2016 = 90659805.50 AND
    YEAR_2016 = 2015 AND
    EMPLOYER_STATE_2016 = 'CA';

--make changes to rows in prevailing_wage
UPDATE H1B2016
SET PREVAILING_WAGE_2016 = 906598.05
WHERE PREVAILING_WAGE_2016 = 9065980.55


------------CLEAN 2017-------------------------------------------------------Changing data types, dropping unecessary columns, editing column names, dropping unecessary rows

--SELECT ALL
SELECT *
FROM H1B2017

--view data type of columns in table
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'H1B2017'

--delete rows for non h1b visa
DELETE FROM H1B2017 WHERE VISA_CLASS <> 'H-1B';

---drop columns 2017.Not needed in the analysis
ALTER TABLE H1B2017
DROP COLUMN ORIGINAL_CERT_DATE, WORKSITE_POSTAL_CODE, WORKSITE_COUNTY, WORKSITE_CITY, PUBLIC_DISCLOSURE_LOCATION, LABOR_CON_AGREE, SUPPORT_H1B, WILLFUL_VIOLATOR, WAGE_UNIT_OF_PAY
			, WAGE_RATE_OF_PAY_TO, WAGE_RATE_OF_PAY_FROM, PW_SOURCE_OTHER, PW_SOURCE_YEAR, PW_SOURCE, PW_WAGE_LEVEL, FULL_TIME_POSITION, AMENDED_PETITION, CHANGE_EMPLOYER,
			NEW_CONCURRENT_EMPLOYMENT, CASE_NUMBER, CASE_SUBMITTED, DECISION_DATE, CHANGE_PREVIOUS_EMPLOYMENT, CONTINUED_EMPLOYMENT, NEW_EMPLOYMENT, TOTAL_WORKERS, NAICS_CODE, 
			SOC_CODE, AGENT_ATTORNEY_STATE, AGENT_ATTORNEY_CITY,AGENT_ATTORNEY_NAME, AGENT_REPRESENTING_EMPLOYER, EMPLOYER_PHONE_EXT, EMPLOYER_PHONE,EMPLOYER_PROVINCE, 
			EMPLOYER_COUNTRY, EMPLOYER_POSTAL_CODE, WORKSITE_STATE,EMPLOYER_CITY, EMPLOYER_ADDRESS, EMPLOYER_BUSINESS_DBA, VISA_CLASS, EMPLOYMENT_END_DATE;

--change data type of prevailing_wage column to money
ALTER TABLE H1B2017
ALTER COLUMN PREVAILING_WAGE money;

--add columns
ALTER TABLE H1B2017
ADD YEAR INT;

--change Employment start date to year
UPDATE H1B2017
SET [YEAR] = YEAR([EMPLOYMENT_START_DATE]);

ALTER TABLE h1b2017
DROP COLUMN EMPLOYMENT_START_DATE;


RenameAllColumns 'H1B2017', 'CASE_STATUS', '_2017';
RenameAllColumns 'H1B2017', 'EMPLOYER_NAME', '_2017';
RenameAllColumns 'H1B2017', 'EMPLOYER_STATE', '_2017';
RenameAllColumns 'H1B2017', 'JOB_TITLE', '_2017';
RenameAllColumns 'H1B2017', 'SOC_NAME', '_2017';
RenameAllColumns 'H1B2017', 'PREVAILING_WAGE', '_2017';
RenameAllColumns 'H1B2017', 'PW_UNIT_OF_PAY', '_2017';
RenameAllColumns 'H1B2017', 'YEAR', '_2017';



---------------CLEAN 2018------------------------------------------------------- Changing data types, dropping unecessary columns, editing column names, dropping unecessary rows
--SELECT ALL
SELECT *
FROM H1B2018

--view data type of columns in table
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'H1B2018'

--delete rows for non h1b visa
DELETE FROM H1B2018 WHERE VISA_CLASS <> 'H-1B';

---drop columns 2018. Not needed in the analysis
ALTER TABLE H1B2018
DROP COLUMN WAGE_UNIT_OF_PAY, WAGE_RATE_OF_PAY_TO, WAGE_RATE_OF_PAY_FROM, FULL_TIME_POSITION, SOC_CODE, EMPLOYER_POSTAL_CODE, EMPLOYER_CITY, EMPLOYMENT_END_DATE,
			VISA_CLASS, DECISION_DATE, CASE_SUBMITTED, CASE_NUMBER;

--change data type of prevailing_wage column to money
ALTER TABLE H1B2018
ALTER COLUMN PREVAILING_WAGE money;

--change Employment start date to year
ALTER TABLE H1B2018
ADD YEAR INT;

UPDATE H1B2018
SET [YEAR] = YEAR([EMPLOYMENT_START_DATE]);
---Not needed again 
ALTER TABLE h1b2018
DROP COLUMN EMPLOYMENT_START_DATE;

RenameAllColumns 'H1B2018', 'CASE_STATUS', '_2018';
RenameAllColumns 'H1B2018', 'EMPLOYER_NAME', '_2018';
RenameAllColumns 'H1B2018', 'EMPLOYER_STATE', '_2018';
RenameAllColumns 'H1B2018', 'JOB_TITLE', '_2018';
RenameAllColumns 'H1B2018', 'SOC_NAME', '_2018';
RenameAllColumns 'H1B2018', 'PREVAILING_WAGE', '_2018';
RenameAllColumns 'H1B2018', 'PW_UNIT_OF_PAY', '_2018';
RenameAllColumns 'H1B2018', 'YEAR', '_2018';



-------RENAME COLUMNS IN EACH DATABASE- STORED PROCEDURE-------------------------------------

ALTER PROCEDURE RenameAllColumns (@TableName NVARCHAR(50), @ColumnName NVARCHAR(50), @Suffix NVARCHAR(50))
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'EXEC sp_rename ''' + QUOTENAME(@TableName) + '.[' + @ColumnName + ']'', ''' + @ColumnName + @Suffix + ''', ''COLUMN'';';
    EXEC sp_executesql @sql;
END


-----------------------------------ANALYZING---------------------------------------------------------------------------
--Get the count of applications 
---Only for 2015-2018 data
ALTER PROCEDURE getApplicationCount (@year int)
AS
BEGIN
	SELECT year,COUNT(*) AS total
	FROM 
		(SELECT year_2016 AS year 
		FROM h1b2016

		UNION ALL

		SELECT year_2017 AS year 
		FROM h1b2017

		UNION ALL

		SELECT year_2018 AS year 
		FROM h1b2018
		) AS combined
	WHERE year >= @year AND year < 2019
	GROUP BY year
END

---Get the count of applications for each state.
ALTER PROCEDURE getApplicationPerStateCount (@State varchar(50))
AS
BEGIN
	SELECT state, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT employer_state_2016 AS state, 
				COUNT(*) AS total_count 
		FROM h1b2016 
		WHERE employer_state_2016 = @State OR 'ALL' = @State
		GROUP BY employer_state_2016 

		UNION ALL 

		SELECT employer_state_2017 AS state, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE employer_state_2017 = @State OR 'ALL' = @State
		GROUP BY employer_state_2017 

		UNION ALL 

		SELECT employer_state_2018 AS state, 
				COUNT(*) AS total_count 
		FROM h1b2018
		WHERE employer_state_2018 = @State OR 'ALL' = @State
		GROUP BY employer_state_2018
		) AS combined_data
	WHERE state != NULL OR state != ''
	GROUP BY state 
	ORDER BY state
END


---Get the count of applications deniend, accepted etc
ALTER PROCEDURE getApplicationPerCaseStatus (@caseStatus varchar(50))
AS
BEGIN
	SELECT case_status, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT CASE_STATUS_2016 AS case_status, 
				COUNT(*) AS total_count
		FROM h1b2016 
		 WHERE CASE_STATUS_2016 = @caseStatus OR 'ALL' = @caseStatus
		GROUP BY CASE_STATUS_2016

		UNION ALL 

		SELECT CASE_STATUS_2017 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = @caseStatus OR 'ALL' = @caseStatus
		GROUP BY CASE_STATUS_2017

		UNION ALL 

		SELECT CASE_STATUS_2018 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = @caseStatus OR 'ALL' = @caseStatus
		GROUP BY CASE_STATUS_2018
		) AS combined_data
	GROUP BY case_status
	ORDER BY case_status
END

---Get the count of applications deniend, accepted etc in 2015
ALTER PROCEDURE getApplicationPerCaseStatus2015 (@caseStatus varchar(50))
AS
BEGIN
	SELECT case_status, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT CASE_STATUS_2016 AS case_status, 
				COUNT(*) AS total_count
		FROM h1b2016 
		 WHERE (CASE_STATUS_2016 = @caseStatus OR 'ALL' = @caseStatus) AND(YEAR_2016 = 2015) 
		GROUP BY CASE_STATUS_2016

		UNION ALL 

		SELECT CASE_STATUS_2017 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2017 = 2015) 
		GROUP BY CASE_STATUS_2017

		UNION ALL 

		SELECT CASE_STATUS_2018 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2018 = 2015) 
		GROUP BY CASE_STATUS_2018
		) AS combined_data
	GROUP BY case_status
	ORDER BY case_status
END

---Get the count of applications deniend, accepted etc in 2016
CREATE PROCEDURE getApplicationPerCaseStatus2016 (@caseStatus varchar(50))
AS
BEGIN
	SELECT case_status, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT CASE_STATUS_2016 AS case_status, 
				COUNT(*) AS total_count
		FROM h1b2016 
		 WHERE (CASE_STATUS_2016 = @caseStatus OR 'ALL' = @caseStatus) AND(YEAR_2016 = 2016) 
		GROUP BY CASE_STATUS_2016

		UNION ALL 

		SELECT CASE_STATUS_2017 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2017 = 2016) 
		GROUP BY CASE_STATUS_2017

		UNION ALL 

		SELECT CASE_STATUS_2018 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2018 = 2016) 
		GROUP BY CASE_STATUS_2018
		) AS combined_data
	GROUP BY case_status
	ORDER BY case_status
END

---Get the count of applications deniend, accepted etc in 2017
CREATE PROCEDURE getApplicationPerCaseStatus2017 (@caseStatus varchar(50))
AS
BEGIN
	SELECT case_status, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT CASE_STATUS_2016 AS case_status, 
				COUNT(*) AS total_count
		FROM h1b2016 
		 WHERE (CASE_STATUS_2016 = @caseStatus OR 'ALL' = @caseStatus) AND(YEAR_2016 = 2017) 
		GROUP BY CASE_STATUS_2016

		UNION ALL 

		SELECT CASE_STATUS_2017 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2017 = 2017) 
		GROUP BY CASE_STATUS_2017

		UNION ALL 

		SELECT CASE_STATUS_2018 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2018 = 2017) 
		GROUP BY CASE_STATUS_2018
		) AS combined_data
	GROUP BY case_status
	ORDER BY case_status
END

---Get the count of applications deniend, accepted etc in 2018
CREATE PROCEDURE getApplicationPerCaseStatus2018 (@caseStatus varchar(50))
AS
BEGIN
	SELECT case_status, 
			SUM(total_count) AS total_count 
	FROM 
		(SELECT CASE_STATUS_2016 AS case_status, 
				COUNT(*) AS total_count
		FROM h1b2016 
		 WHERE (CASE_STATUS_2016 = @caseStatus OR 'ALL' = @caseStatus) AND(YEAR_2016 = 2018) 
		GROUP BY CASE_STATUS_2016

		UNION ALL 

		SELECT CASE_STATUS_2017 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2017 = 2018) 
		GROUP BY CASE_STATUS_2017

		UNION ALL 

		SELECT CASE_STATUS_2018 AS case_status, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = @caseStatus OR 'ALL' = @caseStatus AND(YEAR_2018 = 2018) 
		GROUP BY CASE_STATUS_2018
		) AS combined_data
	GROUP BY case_status
	ORDER BY case_status
END


--This procedure shows the amount of applications that each company filed for H1B VISA sponsorship. This includes certified cases, withdrawn cases, denied cases 
--and certified-withdrawn cases
ALTER PROCEDURE getApplicationPerCompany (@company varchar(50), @limitIfAll int = NULL)
AS
BEGIN
	IF (@company = 'ALL' AND @limitIfAll IS NULL)
	BEGIN
		RAISERROR('The limitIfAll parameter is required.', 16, 1)
		RETURN
	END

	SELECT TOP(@limitIfAll)
			employer,
			SUM(total_count) AS total_count 
	FROM 
		(SELECT EMPLOYER_NAME_2016 AS employer, 
				COUNT(*) AS total_count 
		FROM h1b2016 
		WHERE EMPLOYER_NAME_2016 = @company OR 'ALL' = @company
		GROUP BY EMPLOYER_NAME_2016

		UNION ALL 

		SELECT EMPLOYER_NAME_2017 AS employer, 
				COUNT(*) AS total_count 
		FROM h1b2017 
		WHERE EMPLOYER_NAME_2017 = @company OR 'ALL' = @company
		GROUP BY EMPLOYER_NAME_2017

		UNION ALL 

		SELECT EMPLOYER_NAME_2018 AS employer, 
				COUNT(*) AS total_count 
		FROM h1b2018 
		WHERE EMPLOYER_NAME_2018 = @company OR 'ALL' = @company
		GROUP BY EMPLOYER_NAME_2018
		) AS combined_data
	GROUP BY employer
	ORDER BY total_count DESC
END


---The jobs with the most h1bVISA sponsorship when ordered by count. It shows more STEM jobs than non-stem Jobs. Shows more comp sci based jobs than others. 
--It shows People that applied and actually got it
ALTER PROCEDURE getApplicationPerJob (@job varchar(50), @limitIfAll int = NULL)
AS
BEGIN
	IF (@job = 'ALL' AND @limitIfAll IS NULL)
	BEGIN
		RAISERROR('The limitIfAll parameter is required.', 16, 1)
		RETURN
	END

	SELECT TOP(@limitIfAll)
			job, 
			SUM(total_count) AS total_count
	FROM 
		(SELECT JOB_TITLE_2016 AS job, 
				COUNT(*) AS total_count
		FROM h1b2016 
		WHERE CASE_STATUS_2016 = 'CERTIFIED' 
		  AND (JOB_TITLE_2016 = @job OR 'ALL' = @job)
		GROUP BY JOB_TITLE_2016
	
		UNION ALL 
	
		SELECT 	JOB_TITLE_2017 AS employer, 
				COUNT(*) AS total_count
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = 'CERTIFIED' 
		  AND (JOB_TITLE_2017 = @job OR 'ALL' = @job)
		GROUP BY JOB_TITLE_2017
	
		UNION ALL 
	
		SELECT	JOB_TITLE_2018 AS employer, 
				COUNT(*) AS total_count
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = 'CERTIFIED' 
		  AND (JOB_TITLE_2018 = @job OR 'ALL' = @job)
		GROUP BY JOB_TITLE_2018
		) AS combined_data
	GROUP BY job
	ORDER BY total_count DESC
END


---The jobs with the highest salary. It shows more STEM jobs than non-stem Jobs.It shows People that applied and actually got it
ALTER PROCEDURE getAvgSalaryPerJob  (@jobTitle varchar(50), @limitIfAll int = NULL)
AS
BEGIN

	IF (@jobTitle = 'ALL' AND @limitIfAll IS NULL)
	BEGIN
		RAISERROR('The limitIfAll parameter is required.', 16, 1)
		RETURN
	END

	SELECT TOP(@limitIfAll)
			job, 
			AVG(salary_avg) AS avg_salary, SUM(total_count) AS total_count
	FROM 
		(SELECT JOB_TITLE_2016 AS job, 
			AVG(PREVAILING_WAGE_2016) AS salary_avg, COUNT(*) AS total_count
		FROM h1b2016 
		WHERE CASE_STATUS_2016 = 'CERTIFIED' AND (JOB_TITLE_2016 = @jobTitle OR 'ALL' = @jobTitle)
		GROUP BY JOB_TITLE_2016

		UNION ALL 

		SELECT JOB_TITLE_2017 AS employer, 
			AVG(PREVAILING_WAGE_2017) AS salary_avg,  COUNT(*) AS total_count
		FROM h1b2017 
		WHERE CASE_STATUS_2017 = 'CERTIFIED' AND PW_UNIT_OF_PAY_2017 = 'Year' AND (JOB_TITLE_2017 = @jobTitle OR 'ALL' = @jobTitle)
		GROUP BY JOB_TITLE_2017

		UNION ALL 

		SELECT JOB_TITLE_2018 AS employer, 
			AVG(PREVAILING_WAGE_2018) AS salary_avg,  COUNT(*) AS total_count
		FROM h1b2018 
		WHERE CASE_STATUS_2018 = 'CERTIFIED' AND PW_UNIT_OF_PAY_2018 = 'Year' AND (JOB_TITLE_2018 = @jobTitle OR 'ALL' = @jobTitle)
		GROUP BY JOB_TITLE_2018
		) AS combined_data
	GROUP BY job
	ORDER BY avg_salary DESC
END

-------------------------------CREATING USERS--------------------
---User One
CREATE LOGIN PUBLICUSER WITH PASSWORD = N'Public'
CREATE USER GENERAL FOR LOGIN PUBLICUSER

--Grant Public authority to select and view the tables
GRANT SELECT ON H1B2016 TO PUBLIC
GRANT SELECT ON H1B2017 TO PUBLIC
GRANT SELECT ON H1B2018 TO PUBLIC


----User Two
CREATE LOGIN APPINTERN WITH PASSWORD = N'Intern'
CREATE USER INTERN FOR LOGIN APPINTERN

--Grant Intern authority to select and insert into the tables
GRANT SELECT, INSERT ON H1B2016 TO INTERN
GRANT SELECT, INSERT ON H1B2017 TO INTERN
GRANT SELECT, INSERT ON H1B2018 TO INTERN

--to grant stored procedures
GRANT EXECUTE ON getApplicationCount TO INTERN
GRANT EXECUTE ON getApplicationPerStateCount TO INTERN
GRANT EXECUTE ON getApplicationPerCaseStatus TO INTERN
GRANT EXECUTE ON getApplicationPerCompany TO INTERN
GRANT EXECUTE ON getApplicationPerJob TO INTERN
GRANT EXECUTE ON getAvgSalaryPerJob TO INTERN

--Deny the Intern access to delete data from the tables
DENY DELETE ON H1B2016 TO INTERN
DENY DELETE ON H1B2017 TO INTERN
DENY DELETE ON H1B2018 TO INTERN
 
