--CREATE DATABASE--

CREATE DATABASE case_study; 


---------------------------------------------------------------------------------
--DATA CLEANING, MANIPULATION and TRANSFORMATION--

--Display Data (Familiarize and observe the data)

SELECT *
FROM case_study.dbo.daily_activity;

SELECT COUNT(*)
FROM case_study.dbo.daily_activity;



--Check number of sample in the data (there are 33 unique id)

SELECT COUNT(DISTINCT id)
FROM case_study.dbo.daily_activity; 



--See data type and size of table
USE case_study
EXEC sp_help 'daily_activity'



--Fix data type 

ALTER TABLE daily_activity
ALTER COLUMN Id BIGINT;

ALTER TABLE daily_activity
ALTER COLUMN ActivityDate DATE;

ALTER TABLE daily_activity
ALTER COLUMN TotalSteps INT;

ALTER TABLE daily_activity
ALTER COLUMN TotalDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN TrackerDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN LoggedActivitiesDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN VeryActiveDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN ModeratelyActiveDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN LightActiveDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN SedentaryActiveDistance FLOAT;

ALTER TABLE daily_activity
ALTER COLUMN VeryActiveMinutes INT;

ALTER TABLE daily_activity
ALTER COLUMN FairlyActiveMinutes INT;

ALTER TABLE daily_activity
ALTER COLUMN LightlyActiveMinutes INT;

ALTER TABLE daily_activity
ALTER COLUMN SedentaryMinutes INT;

ALTER TABLE daily_activity
ALTER COLUMN Calories INT;



--Confirm data type 
USE case_study
EXEC sp_help 'daily_activity'



--Check length of ID number and see if there are ID that has different length

SELECT Id, LEN(Id) AS id_length
FROM case_study.dbo.daily_activity
GROUP BY Id;

SELECT Id, LEN(Id) AS id_length
FROM case_study.dbo.daily_activity
WHERE LEN(id) <>10
GROUP BY Id;



--Check for any missing values or NULL

SELECT Id 
FROM case_study.dbo.daily_activity
WHERE Id =' '; --(no missing values)

SELECT ActivityDate
FROM case_study.dbo.daily_activity
WHERE ActivityDate =' '; --(no missing values)

SELECT Id, ActivityDate, Calories
FROM case_study.dbo.daily_activity
WHERE Calories =' '; --(there are 4 Id with 0 calories)

SELECT Id, ActivityDate,TotalSteps, TotalDistance, TrackerDistance
FROM case_study.dbo.daily_activity
WHERE TotalSteps =' '; --(if totalSteps 0, TotalDistance and TrackerDistance should be 0)



--Find and Remove Duplicate 

SELECT Id, ActivityDate, COUNT(*)
FROM case_study.dbo.daily_activity
GROUP BY Id, ActivityDate;

SELECT Id, ActivityDate, COUNT(*)
FROM case_study.dbo.daily_activity
GROUP BY Id, ActivityDate
HAVING COUNT(*) > 1;



---------------------------------------------------------------------------------
--ORGANIZE DATA--

--Creating New Column (Activity Day)

SELECT ActivityDate, DATENAME(WEEKDAY, ActivityDate) AS ActivityDay
FROM case_study.dbo.daily_activity;

ALTER TABLE daily_activity
ADD ActivityDay VARCHAR(10);

UPDATE daily_activity
SET ActivityDay = DATENAME(WEEKDAY, ActivityDate);



--Add New Column for Total Minutes and Total Hours	

SELECT Id, (VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes) AS TotalMinutes
FROM case_study.dbo.daily_activity;

ALTER TABLE daily_activity
ADD TotalMinutes INT;

UPDATE daily_activity
SET TotalMinutes =(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes);


SELECT Id, ((VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes)/60) AS TotalHours
FROM case_study.dbo.daily_activity;

ALTER TABLE daily_activity
ADD TotalHours INT;

UPDATE daily_activity
SET TotalHours =((VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes)/60);



--Review Data

SELECT Id, ActivityDate, ActivityDay,TotalMinutes, TotalHours, TotalSteps, Calories
FROM case_study.dbo.daily_activity;



--DATA Analysis (Answer Question)--

--Which day of the week has is the most active based on the daily user log ?
SELECT ActivityDay, COUNT(ActivityDay) AS TotalActivityLog
FROM case_study.dbo.daily_activity
GROUP BY ActivityDay;

--How many log activity is used in this project?
SELECT COUNT(ActivityDay)
FROM case_study.dbo.daily_activity;

--How many days of activity is recorded in this dataset?
SELECT COUNT(DISTINCT ActivityDate)
FROM case_study.dbo.daily_activity;


--MAX values based on the activity day?
SELECT ActivityDay, MAX(TotalHours) AS MaxHours, MAX(TotalSteps) AS MaxSteps, MAX(TotalDistance) AS MaxDistance, MAX(Calories) AS MaxCalories
FROM case_study.dbo.daily_activity
GROUP BY ActivityDay
ORDER BY MaxSteps DESC;

--Max Hours, Steps, Distance, and Calories from the whole dataset?
SELECT MAX(TotalHours) AS MaxHours, MAX(TotalSteps) AS MaxSteps, MAX(TotalDistance) AS MaxDistance, MAX(Calories) AS MaxCalories
FROM case_study.dbo.daily_activity;


--MIN values based on the activity day?
SELECT ActivityDay, MIN(TotalHours) AS MinHours, MIN(TotalSteps) AS MinSteps,MIN(TotalDistance) AS MinDistance, MIN(Calories) AS MinCalories
FROM case_study.dbo.daily_activity
GROUP BY ActivityDay
ORDER BY MinHours, MinSteps, MinDistance, MinCalories;

--Min Hours, Steps, Distance, and Calories from the whole dataset?
SELECT MIN(TotalHours) AS MinHours, MIN(TotalSteps) AS MinSteps, MIN(TotalDistance) AS MinDistance, MIN(Calories) AS MinCalories
FROM case_study.dbo.daily_activity;


--Mean values based on the activity day?
SELECT ActivityDay, AVG(TotalHours) AS AvgHours, AVG(TotalSteps) AS AvgSteps, AVG(TotalDistance) AS AvgDistance, AVG(Calories) AS AvgCalories
FROM case_study.dbo.daily_activity
GROUP BY ActivityDay
ORDER BY AvgHours, AvgSteps, AvgDistance, AvgCalories;

--Mean of Hours, Steps, Distance, and Calories from the whole dataset?
SELECT AVG(TotalHours) AS AvgHours, AVG(TotalSteps) AS AvgSteps, AVG(TotalDistance) AS AvgDistance, AVG(Calories) AS AvgCalories
FROM case_study.dbo.daily_activity;



--Summary Statistic--(Showing the summary of Max, Mean, and Min in one table)

SELECT 'Mean',
    AVG(TotalHours) AS ActiveHours,
	AVG(TotalSteps) AS Steps,
    AVG(TotalDistance) AS Distance,
	AVG(Calories) AS Calories
FROM case_study.dbo.daily_activity
UNION
SELECT 'Min',
    MIN(TotalHours),
	MIN(TotalSteps),
    MIN(TotalDistance),
	MIN(Calories)
FROM case_study.dbo.daily_activity
UNION
SELECT 'Max',
    MAX(TotalHours),
    MAX(TotalSteps),
	MAX(TotalDistance),
	MAX(Calories)
FROM case_study.dbo.daily_activity;



--What is the most favorite day of overall user to be active and what is the percentage of it during 31days period?
SELECT ActivityDay, 
	COUNT(ActivityDay) AS DayLog,
	CAST(COUNT(*) as decimal(10,2))*100/SUM(COUNT(*)) OVER () AS PercentageLog
FROM case_study.dbo.daily_activity
GROUP BY ActivityDay
ORDER BY PercentageLog DESC;



--Based on the type of user from the Distance Log Types, find out what is the most types of users?
WITH cte_distance AS (
	SELECT *,
		CASE WHEN VeryActiveDistance <>' ' THEN '1' ELSE '0' END AS VeryActive, 
		CASE WHEN ModeratelyActiveDistance <>' ' THEN '1' ELSE '0' END AS ModeratelyActive,
		CASE WHEN LightActiveDistance <>' ' THEN '1' ELSE '0' END AS LightActive,
		CASE WHEN SedentaryActiveDistance <>' ' THEN '1' ELSE '0' END AS SedentaryActive
	FROM case_study.dbo.daily_activity
)
SELECT 'VeryActive' AS DistanceType,
	SUM(CAST(VeryActive AS INT)) AS DistanceLog
FROM cte_distance
UNION
SELECT 'ModeratelyActive',
	SUM(CAST(ModeratelyActive AS INT))
FROM cte_distance
UNION
SELECT 'LightActive',
	SUM(CAST(LightActive AS INT))
FROM cte_distance
UNION
SELECT 'SedentaryActive',
	SUM(CAST(SedentaryActive AS INT))
FROM cte_distance
ORDER BY DistanceLog DESC;


--Find out the intensitiy of users based on the time, what type is the most common? 
WITH cte_minutes AS (
	SELECT *,
		CASE WHEN VeryActiveMinutes <>' ' THEN '1' ELSE '0' END AS VeryActive,
		CASE WHEN FairlyActiveMinutes <>' ' THEN '1' ELSE '0' END AS FairlyActive,
		CASE WHEN LightlyActiveMinutes <>' ' THEN '1' ELSE '0' END AS LightlyActive,
		CASE WHEN SedentaryMinutes <>' ' THEN '1' ELSE '0' END AS Sedentary
	FROM case_study.dbo.daily_activity
)
SELECT 'VeryActive' AS MinutesType,
	SUM(CAST(VeryActive AS INT)) AS MinutesLog
FROM cte_minutes
UNION
SELECT 'FairlyActive',
	SUM(CAST(FairlyActive AS INT))
FROM cte_minutes
UNION
SELECT 'LightlyActive',
	SUM(CAST(LightlyActive AS INT))
FROM cte_minutes
UNION
SELECT 'Sedentary',
	SUM(CAST(Sedentary AS INT))
FROM cte_minutes
ORDER BY MinutesLog DESC;

