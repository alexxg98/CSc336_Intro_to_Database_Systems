DROP DATABASE IF EXISTS assignment3;
CREATE DATABASE assignment3;
use assignment3;

CREATE TABLE CitiBike(
	tripduration INT,
    starttime VARCHAR(30),
    startday VARCHAR(30),
    stoptime VARCHAR(30),
    stopday VARCHAR(30),
    startstationid INT,
    startstationname VARCHAR(225),
    startstationlatitude DECIMAL(10,8),
    startstationlongitude DECIMAL(10,8),
    endstationid INT,
    endstationname VARCHAR(225),
    endstationlatitude DECIMAL(10,8),
    endstationlongitude DECIMAL(10,8),
    bikeid INT,
    usertype ENUM("Customer", "Subscriber"),
    birthyear INT,
    gender INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/2013-07_CitiBikeData.csv'
INTO TABLE CitiBike
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE CitiBike 
SET
startday = date_format(str_to_date(starttime, "%m/%d/%Y %H:%i"), "%W"),
stopday = date_format(str_to_date(stoptime, "%m/%d/%Y %H:%i"), "%W");

CREATE TABLE Stations(
	Id INT PRIMARY KEY, 
	Name VARCHAR(255), 
  	Latitude DECIMAL(10,8), 
   	Longitude DECIMAL(10,8)
);

CREATE TABLE Trips(
	StationId INT PRIMARY KEY, 
	MinTripDuration INT, 
	MaxTripDuration INT, 
	AvgTripDuration INT, 
	NumberStartUsers INT,
	NumberReturnUsers INT,
	FOREIGN KEY(StationId) REFERENCES Stations(Id)
);

DROP TABLE IF EXISTS UsageByDay;
CREATE TABLE UsageByDay(
	StationId INT PRIMARY KEY, 
	NumberWeekdayStartUsers INT, 
	NumberWeekdayReturnUsers INT,
	NumberWeekendStartUsers INT, 
	NumberWeekendReturnUsers INT,
	FOREIGN KEY(StationId) REFERENCES Stations(Id)
);

DROP TABLE IF EXISTS UsageByGender;
CREATE TABLE UsageByGender(
	StationId INT PRIMARY KEY, 
	NumberMaleStartUsers INT, 
	NumberFemaleStartUsers INT,
	NumberMaleReturnUsers INT, 
	NumberFemaleReturnUsers INT,
	FOREIGN KEY(StationId) REFERENCES Stations(Id)
);

CREATE TABLE UsageByAge(
	StationId INT PRIMARY KEY, 
    NumberMaleUsersUnder18 INT, 
    NumberMaleUsers18To40 INT,
	NumberMaleUsersOver40 INT, 
    NumberFemaleUsersUnder18 INT,
	NumberFemaleUsers18To40 INT,
    NumberFemaleUsersOver40 INT,
    FOREIGN KEY(StationId) REFERENCES Stations(Id)
);

INSERT INTO Stations 
SELECT DISTINCT startstationid, startstationname, startstationlatitude, startstationlongitude FROM CitiBike
WHERE NOT EXISTS (SELECT * FROM Stations WHERE startstationid = id)
GROUP BY startstationid
UNION
SELECT DISTINCT endstationid, endstationname, endstationlatitude, endstationlongitude FROM CitiBike
WHERE NOT EXISTS (SELECT * FROM Stations WHERE startstationid = id)
GROUP BY endstationid;

SELECT * FROM Stations;

INSERT INTO Trips
SELECT DISTINCT Sid.id, S.MinTripDuration, S.MaxTripDuration, S.AvgTripDuration, 
	S.NumberStartUsers, E.NumberReturnUsers
FROM (SELECT DISTINCT id FROM Stations) Sid
	LEFT JOIN
	(SELECT DISTINCT startstationid AS StationId,
		MIN(tripduration) AS MinTripDuration, 
		MAX(tripduration) AS MaxTripDuration, 
		FLOOR(AVG(tripduration)) AS AvgTripDuration, 
        COUNT(*) AS NumberStartUsers 
        FROM CitiBike
    WHERE NOT EXISTS (SELECT StationId FROM Trips where Trips.StationId = StationId)
    GROUP BY StationId) S
    ON S.StationId = Sid.id
    LEFT JOIN
	(SELECT DISTINCT endstationid AS StationId,
		COUNT(*) AS NumberReturnUsers
	FROM CitiBike
	WHERE NOT EXISTS (SELECT StationId FROM Trips where Trips.StationId = StationId)
	GROUP BY StationId) E
	ON E.StationId = Sid.id;
    
UPDATE Trips SET 
MinTripDuration = (SELECT MIN(tripduration) FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid)),
MaxTripDuration = (SELECT MAX(tripduration) FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid)),
AvgTripDuration = (SELECT FLOOR(AVG(tripduration)) FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid))
WHERE MinTripDuration IS NULL AND MaxTripDuration IS NULL AND AvgTripDuration IS NULL;

SELECT * FROM Trips ORDER BY StationId;


INSERT INTO UsageByDay
SELECT Sid.id, S.NumberWeekdayStartUsers, E.NumberWeekdayReturnUsers, S.NumberWeekendStartUsers, E.NumberWeekendReturnUsers
FROM (SELECT id from Stations) Sid
	LEFT JOIN
    (SELECT DISTINCT startstationid AS StationId,
		(COUNT(CASE WHEN startday = "Monday" THEN startstationid END) +
			COUNT(CASE WHEN startday = "Tuesday" THEN startstationid END) +
			COUNT(CASE WHEN startday = "Wednesday" THEN startstationid END) +
			COUNT(CASE WHEN startday = "Thursday" THEN startstationid END) +
			COUNT(CASE WHEN startday = "Friday" THEN startstationid END)) AS NumberWeekdayStartUsers,
		(COUNT(CASE WHEN startday = "Saturday" THEN startstationid END) +
			COUNT(CASE WHEN startday = "Sunday" THEN startstationid END)) AS NumberWeekendStartUsers
		FROM CitiBike
        WHERE NOT EXISTS (SELECT StationId FROM UsageByDay where UsageByDay.StationId = StationId)
		GROUP BY StationId) S
	ON S.StationId = Sid.id
    LEFT JOIN
    (SELECT DISTINCT endstationid AS StationId,
		(COUNT(CASE WHEN startday = "Monday" THEN endstationid END) +
			COUNT(CASE WHEN startday = "Tuesday" THEN endstationid END) +
			COUNT(CASE WHEN startday = "Wednesday" THEN endstationid END) +
			COUNT(CASE WHEN startday = "Thursday" THEN endstationid END) +
			COUNT(CASE WHEN startday = "Friday" THEN endstationid END)) AS NumberWeekdayReturnUsers,
		(COUNT(CASE WHEN startday = "Saturday" THEN endstationid END) +
			COUNT(CASE WHEN startday = "Sunday" THEN endstationid END)) AS NumberWeekendReturnUsers
		FROM CitiBike
        WHERE NOT EXISTS (SELECT StationId FROM UsageByDay where UsageByDay.StationId = StationId)
		GROUP BY StationId) E
	ON E.StationId = Sid.id;

SELECT * FROM UsageByDay ORDER BY StationId;


INSERT INTO UsageByGender
SELECT Sid.id, S.NumberMaleStartUsers, S.NumberFemaleStartUsers, E.NumberMaleReturnUsers, E.NumberFemaleReturnUsers
FROM (SELECT id FROM Stations WHERE id IN (SELECT startstationid FROM CitiBike WHERE NOT gender=0)
		OR id IN (SELECT endstationid FROM CitiBike WHERE NOT gender=0)) Sid
	LEFT JOIN
    (SELECT DISTINCT startstationid AS StationId,
		COUNT(CASE WHEN gender = 1 THEN startstationid END) AS NumberMaleStartUsers,
        COUNT(CASE WHEN gender = 2 THEN startstationid END) AS NumberFemaleStartUsers
	FROM CitiBike
    WHERE NOT EXISTS (SELECT StationId FROM UsageByGender where UsageByGender.StationId = StationId)
	GROUP BY StationId) S
	ON S.StationId = Sid.id
    LEFT JOIN
    (SELECT DISTINCT endstationid AS StationId,
		COUNT(CASE WHEN gender = 1 THEN endstationid END) AS NumberMaleReturnUsers,
        COUNT(CASE WHEN gender = 2 THEN endstationid END) AS NumberFemaleReturnUsers
	FROM CitiBike
    WHERE NOT EXISTS (SELECT StationId FROM UsageByGender where UsageByGender.StationId = StationId)
	GROUP BY StationId) E
	ON E.StationId = Sid.id;
    
SELECT * FROM UsageByGender ORDER BY StationId;

SET @Year = 2013;
INSERT INTO UsageByAge
SELECT Sid.id, S.NumberMaleUsersUnder18, S.NumberMaleUsers18To40, S.NumberMaleUsersOver40, S.NumberFemaleUsersUnder18, S.NumberFemaleUsers18To40, S.NumberFemaleUsersOver40
FROM (SELECT id FROM Stations WHERE id IN (SELECT startstationid FROM CitiBike WHERE usertype = "Subscriber")
		OR id IN (SELECT endstationid FROM CitiBike WHERE usertype = "Subscriber")) Sid
	LEFT JOIN
    (SELECT DISTINCT startstationid AS StationId,
		COUNT(CASE WHEN gender=1 AND @Year-birthyear<18 THEN startstationid END) AS NumberMaleUsersUnder18,
        COUNT(CASE WHEN gender=1 AND @Year-birthyear>18 AND @Year-birthyear<40 THEN startstationid END) AS NumberMaleUsers18To40,
        COUNT(CASE WHEN gender=1 AND @Year-birthyear>40 THEN startstationid END) AS NumberMaleUsersOver40,
        COUNT(CASE WHEN gender=2 AND @Year-birthyear<18 THEN startstationid END) AS NumberFemaleUsersUnder18,
        COUNT(CASE WHEN gender=2 AND @Year-birthyear>18 AND @Year-birthyear<40 THEN startstationid END) AS NumberFemaleUsers18To40,
        COUNT(CASE WHEN gender=2 AND @Year-birthyear>40 THEN startstationid END) AS NumberFemaleUsersOver40
	FROM CitiBike WHERE NOT EXISTS (SELECT StationId FROM UsageByAge WHERE UsageByAge.StationId = startstationid) GROUP BY StationId) S
	ON S.StationId = Sid.id;

UPDATE UsageByAge SET
NumberMaleUsersUnder18 = (SELECT DISTINCT COUNT(CASE WHEN gender=1 AND @Year-birthyear<18 THEN endstationid END) 
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid),
NumberMaleUsers18To40 = (SELECT DISTINCT COUNT(CASE WHEN gender=1 AND @Year-birthyear>18 AND @Year-birthyear<40 THEN endstationid END) 
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid),
NumberMaleUsersOver40 = (SELECT DISTINCT COUNT(CASE WHEN gender=1 AND @Year-birthyear>40 THEN endstationid END)
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid),
NumberFemaleUsersUnder18 = (SELECT DISTINCT COUNT(CASE WHEN gender=2 AND @Year-birthyear<18 THEN endstationid END)
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid),
NumberFemaleUsers18To40 = (SELECT DISTINCT COUNT(CASE WHEN gender=2 AND @Year-birthyear>18 AND @Year-birthyear<40 THEN endstationid END)
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid),
NumberFemaleUsersOver40 = (SELECT DISTINCT COUNT(CASE WHEN gender=2 AND @Year-birthyear>40 THEN endstationid END)
						FROM CitiBike WHERE StationId IN (SELECT id FROM Stations WHERE id = endstationid) GROUP BY endstationid)
WHERE NumberMaleUsersUnder18 IS NULL AND NumberMaleUsers18To40 IS NULL AND NumberMaleUsersOver40 IS NULL 
	AND NumberFemaleUsersUnder18 IS NULL AND NumberFemaleUsers18To40 IS NULL AND NumberFemaleUsersOver40 IS NULL;

SELECT * FROM UsageByAge ORDER BY StationId;

SELECT DISTINCT
(SELECT startstationid) AS "Station 1",
(SELECT endstationid) AS "Station 2",
COUNT(CASE WHEN startday = "Monday"  THEN startstationid END) AS "Number of Trips on Monday",
COUNT(CASE WHEN startday = "Tuesday"  THEN startstationid END) AS "Number of Trips on Tuesday",
COUNT(CASE WHEN startday = "Wednesday"  THEN startstationid END) AS "Number of Trips on Wednesday",
COUNT(CASE WHEN startday = "Thursday"  THEN startstationid END) AS "Number of Trips on Thursday",
COUNT(CASE WHEN startday = "Friday"  THEN startstationid END) AS "Number of Trips on Friday",
COUNT(CASE WHEN startday = "Saturday"  THEN startstationid END) AS "Number of Trips on Saturday",
COUNT(CASE WHEN startday = "Sunday"  THEN startstationid END) AS "Number of Trips on Sunday"
FROM CitiBike
GROUP BY startstationid, endstationid;

SELECT DISTINCT startstationid AS 'Vacant Station' FROM CitiBike 
	WHERE startstationid NOT IN (SELECT endstationid FROM CitiBike);
    
SELECT DISTINCT endstationid AS 'Dormant Station' FROM CitiBike 
	WHERE endstationid NOT IN (SELECT startstationid FROM CitiBike);

SELECT * FROM CitiBike;
SELECT * FROM Stations;
SELECT * FROM Trips ORDER BY StationId;
SELECT * FROM UsageByDay ORDER BY StationId;
SELECT * FROM UsageByGender ORDER BY StationId;
SELECT * FROM UsageByAge ORDER BY StationId;