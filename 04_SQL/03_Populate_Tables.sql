

USE CTA;
GO


-- The purpose of this script is to populates the data in all dimension tables, views, and calculate the persistent values


-- Live Latest Alerts Table Preview (Data populated in last script)
SELECT
	RecordID, RecordType,
	RouteName, RouteStatus, RouteColorCode,
	FetchedDate, FetchedTime,
	AlertSeverityRange, RouteStatusCategory
FROM Live_Latest_Alerts;

-- Populate data in Train Route Dimension Table
INSERT INTO Train_Route_Dim(TrainRouteID, TrainRouteName, TrainColorCode)
SELECT DISTINCT m.RouteID, m.RouteName, m.RouteColorCode
FROM Master_Alerts AS m
WHERE m.RecordType = 'Rail'
	AND NOT EXISTS(
	SELECT 1
	FROM Train_Route_Dim AS t
	WHERE t.TrainRouteID = m.RouteID
	);

-- Train Route Dimension Preview
SELECT
	TrainRouteID, TrainRouteName
FROM Train_Route_Dim;

-- Calculate and populate data in Persistent Train Alerts Dimension table
-- If a Train Route current statuses matches its last 4 recorded statuses, treat it as a persistent issue and return it with its Status Category and Severity Level.

WITH Filter_Train_Data AS(
	SELECT RouteID, RouteName, RouteStatus, FetchedDate, FetchedTime
	FROM Live_Latest_Alerts
	WHERE RecordType = 'Rail' AND RouteStatus <> 'Normal Service'

),
Get_Route_Statuses AS(
	SELECT
		g.RouteID, g.RouteName,
		g.RouteStatus AS [Latest Status],
		l.RouteStatus AS [Previous Status],
		g.FetchedDate AS [Current Date],
		l.DateID AS [All Dates],
		g.FetchedTime, l.Time
	FROM Filter_Train_Data AS g
	INNER JOIN Live_Alerts_Fact AS l
		ON g.RouteID = l.TrainRouteID
		AND g.FetchedDate = l.DateID
		AND l.RouteStatus <> 'Normal Service'
),
Rank_by_Time AS(
	SELECT
		RouteID, RouteName,
		[Latest Status], [Previous Status],
		FetchedTime, Time, [All Dates],
		ROW_NUMBER() OVER(PARTITION BY RouteID ORDER BY [All Dates] DESC, Time DESC) AS Ranking
	FROM Get_Route_Statuses
),

Get_Previous_Statuses AS(
	SELECT
		RouteID, RouteName, [Latest Status], [Previous Status], FetchedTime, Time, Ranking,
		LEAD([Previous Status], 1) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_First_Status,
		LEAD([Previous Status], 2) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Second_Status,
		LEAD([Previous Status], 3) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Third_Status,
		LEAD([Previous Status], 4) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Fourth_Status
	FROM Rank_by_Time
	WHERE Ranking <= 5
),
Add_Columns AS(
	SELECT
		RouteID AS [Train Route ID],
		RouteName AS [Train Route Name],
		[Latest Status] AS [Persistent Status],
		CASE
			WHEN [Latest Status] IN (
					'Added Service', 'Bus Stop Note', 'Special Note', 'Planned Reroute', 'Planned Work',
					'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Disruption'
			WHEN [Latest Status] IN ('Minor Delays', 'Minor Delays / Reroute', 'Major Delays') THEN 'Delay'
			ELSE 'Other'
		END AS [Persistent Status Category],
		CASE
			WHEN [Latest Status] IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN [Latest Status] IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN [Latest Status] IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN [Latest Status] = 'Major Delays' THEN '80-99'  
			ELSE '60-79'
		END AS [Severity Level]
	FROM Get_Previous_Statuses
	WHERE
		Previous_Fourth_Status IS NOT NULL
		AND [Latest Status] IN (Previous_First_Status, Previous_Second_Status, Previous_Third_Status, Previous_Fourth_Status)

)
INSERT INTO Persistent_Train_Alerts_Dim(TrainRouteID, TrainRouteName, RouteStatus, PersistentStatusCategory, SeverityLevel)
SELECT [Train Route ID], [Train Route Name], [Persistent Status], [Persistent Status Category], [Severity Level]
FROM Add_Columns;

-- Persistent Train Alerts Dimension Preview
SELECT
	TrainRouteID, TrainRouteName,
	RouteStatus, PersistentStatusCategory, SeverityLevel
FROM Persistent_Train_Alerts_Dim;

-- Populate data in Bus Route Dimension Table 
INSERT INTO Bus_Route_Dim(BusRouteID, BusRouteName)
SELECT DISTINCT m.RouteID, m.RouteName 
FROM Master_Alerts AS m
WHERE m.RecordType = 'Bus'
	AND NOT EXISTS(
	SELECT 1
	FROM Bus_Route_Dim AS b
	WHERE b.BusRouteID = m.RouteID
	);

-- Bus Route Dimension Preview
SELECT BusRouteID, BusRouteName
FROM Bus_Route_Dim;


-- Calculate and populate data in Persistent Bus Alerts Dim
-- If a Bus Route current statuses matches its last 4 recorded statuses, treat it as a persistent issue and return it with its Status Category and Severity Level.


WITH Filter_Bus_Data AS(
	SELECT RouteID, RouteName, RouteStatus, FetchedDate, FetchedTime
	FROM Live_Latest_Alerts
	WHERE RecordType = 'Bus' AND RouteStatus <> 'Normal Service'

),
Get_Route_Statuses AS(
	SELECT
		g.RouteID, g.RouteName,
		g.RouteStatus AS [Latest Status],
		l.RouteStatus AS [Previous Status],
		g.FetchedDate AS [Current Date],
		l.DateID AS [All Dates],
		g.FetchedTime, l.Time
	FROM Filter_Bus_Data AS g
	INNER JOIN Live_Alerts_Fact AS l
		ON g.RouteID = l.BusRouteID
		AND g.FetchedDate = l.DateID
		AND l.RouteStatus <> 'Normal Service'
	
),
Rank_by_Time AS(
	SELECT
		RouteID, RouteName,
		[Latest Status], [Previous Status],
		FetchedTime, Time, [All Dates],
		ROW_NUMBER() OVER(PARTITION BY RouteID ORDER BY [All Dates] DESC, Time DESC) AS Ranking
	FROM Get_Route_Statuses
),
Get_Previous_Statuses AS(
	SELECT
		RouteID, RouteName, [Latest Status], [Previous Status], FetchedTime, Time, Ranking,
		LEAD([Previous Status], 1) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_First_Status,
		LEAD([Previous Status], 2) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Second_Status,
		LEAD([Previous Status], 3) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Third_Status,
		LEAD([Previous Status], 4) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Fourth_Status
		
	FROM Rank_by_Time
	WHERE Ranking <= 5


),
Add_Columns AS(
	SELECT
		RouteID AS [Bus Route ID],
		RouteName AS [Bus Route Name],
		[Latest Status] AS [Persistent Status],
		CASE
			WHEN [Latest Status] IN (
					'Added Service', 'Bus Stop Note', 'Special Note', 'Planned Reroute', 'Planned Work',
					'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Disruption'
			WHEN [Latest Status] IN ('Minor Delays', 'Minor Delays / Reroute', 'Major Delays') THEN 'Delay'
			ELSE 'Other'
		END AS [Persistent Status Category],
		CASE
			WHEN [Latest Status] IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN [Latest Status] IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN [Latest Status] IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN [Latest Status] = 'Major Delays' THEN '80-99'  
			ELSE '60-79'
		END AS [Severity Level]
	FROM Get_Previous_Statuses
	WHERE
		Previous_Fourth_Status IS NOT NULL
		AND [Latest Status] IN (Previous_First_Status, Previous_Second_Status, Previous_Third_Status, Previous_Fourth_Status)

)

INSERT INTO Persistent_Bus_Alerts_Dim(BusRouteID, BusRouteName, RouteStatus, PersistentStatusCategory, SeverityLevel)
SELECT [Bus Route ID], [Bus Route Name], [Persistent Status], [Persistent Status Category], [Severity Level]
FROM Add_Columns;

-- Persistent Bus Alerts Dimension Preview
SELECT
	BusRouteID, BusRouteName,
	RouteStatus, PersistentStatusCategory, SeverityLevel
FROM Persistent_Bus_Alerts_Dim;


-- Populate data in Systemwide Route Dimension table
INSERT INTO Systemwide_Route_Dim(SystemwideRouteID, SystemwideRouteName)
SELECT DISTINCT m.RouteID, m.RouteName
FROM Master_Alerts AS m
WHERE m.RecordType = 'Systemwide'
AND NOT EXISTS (
	SELECT 1
	FROM Systemwide_Route_Dim AS s
	WHERE m.RouteID = s.SystemwideRouteID
);

-- Systemwide Route Dimension Table Preview
SELECT
	SystemwideRouteID, SystemwideRouteName
FROM Systemwide_Route_Dim;

-- Calculate and populate data in Persistent Systemwide Route Alerts Dimension Table
-- If a Systemwide Route current statuses matches its last 4 recorded statuses, treat it as a persistent issue and return it with its Status Category and Severity Level.

WITH Filter_Systemwide_Data AS(
	SELECT RouteID, RouteName, RouteStatus, FetchedDate, FetchedTime
	FROM Live_Latest_Alerts
	WHERE RecordType = 'Systemwide' AND RouteStatus <> 'Normal Service'

),
Get_Route_Statuses AS(
	SELECT
		g.RouteID, g.RouteName,
		g.RouteStatus AS [Latest Status],
		l.RouteStatus AS [Previous Status],
		g.FetchedDate AS [Current Date],
		l.DateID AS [All Dates],
		g.FetchedTime, l.Time
	FROM Filter_Systemwide_Data AS g
	INNER JOIN Live_Alerts_Fact AS l
		ON g.RouteID = l.SystemwideRouteID
		AND g.FetchedDate = l.DateID
		AND l.RouteStatus <> 'Normal Service'
),
Rank_by_Time AS(
	SELECT
		RouteID, RouteName,
		[Latest Status], [Previous Status],
		FetchedTime, Time, [All Dates],
		ROW_NUMBER() OVER(PARTITION BY RouteID ORDER BY [All Dates] DESC, Time DESC) AS Ranking
	FROM Get_Route_Statuses
),

Get_Previous_Statuses AS(
	SELECT
		RouteID, RouteName, [Latest Status], [Previous Status], FetchedTime, Time, Ranking,
		LEAD([Previous Status], 1) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_First_Status,
		LEAD([Previous Status], 2) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Second_Status,
		LEAD([Previous Status], 3) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Third_Status,
		LEAD([Previous Status], 4) OVER(PARTITION BY RouteID ORDER BY Time DESC ) AS Previous_Fourth_Status
	FROM Rank_by_Time
	WHERE Ranking <= 5
),
Add_Columns AS(
	SELECT
		RouteID AS [Systemwide Route ID],
		RouteName AS [Systemwide Route Name],
		[Latest Status] AS [Persistent Status],
		CASE
			WHEN [Latest Status] IN (
					'Added Service', 'Bus Stop Note', 'Special Note', 'Planned Reroute', 'Planned Work',
					'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Disruption'
			WHEN [Latest Status] IN ('Minor Delays', 'Minor Delays / Reroute', 'Major Delays') THEN 'Delay'
			ELSE 'Other'
		END AS [Persistent Status Category],
		CASE
			WHEN [Latest Status] IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN [Latest Status] IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN [Latest Status] IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN [Latest Status] = 'Major Delays' THEN '80-99'  
			ELSE '60-79'
		END AS [Severity Level]
	FROM Get_Previous_Statuses
	WHERE
		Previous_Fourth_Status IS NOT NULL
		AND [Latest Status] IN (Previous_First_Status, Previous_Second_Status, Previous_Third_Status, Previous_Fourth_Status)

)

INSERT INTO Persistent_Systemwide_Alerts_Dim(SystemwideRouteID, SystemwideRouteName, RouteStatus, PersistentStatusCategory, SeverityLevel)
SELECT [Systemwide Route ID], [Systemwide Route Name], [Persistent Status], [Persistent Status Category], [Severity Level]
FROM Add_Columns;

-- Persistent Systemwdie Alerts Dimension Table Preview
SELECT
	SystemwideRouteID, SystemwideRouteName,
	RouteStatus, PersistentStatusCategory, SeverityLevel
FROM Persistent_Systemwide_Alerts_Dim;

-- Calendar Dim
WITH DateSequence AS(
	SELECT CAST('2026-08-22' AS DATE) AS DateID

	UNION ALL 

	SELECT DATEADD(DAY, 1, DateID)
	FROM DateSequence
	WHERE DateID <= '2026-08-29'

)
INSERT INTO Calendar_Dim(DateID)
SELECT DateID
FROM DateSequence
OPTION (MAXRECURSION 200);

UPDATE Calendar_Dim
SET Year = YEAR(DateID),
Quarter = DATEPART(QUARTER, DateID),
MonthName = DATENAME(MONTH, DateID),
MonthShortForm = LEFT(DATENAME(MONTH, DateID), 3),
MonthNumber = DATEPART(MONTH, DateID),
WeekNumber = DATEPART(WEEK, DateID),
Weekday = DATENAME(WEEKDAY, DateID),
WeekdayShortForm = LEFT(DATENAME(WEEKDAY, DateID), 3)

-- Calendar Dimension Preview
SELECT
	DateID, Year, Quarter,
	MonthName, MonthShortForm, MonthNumber,
	WeekNumber, Weekday, WeekdayShortForm
FROM Calendar_Dim;

-- Time Dim
WITH TimeSequence AS(
	SELECT CAST(0 AS INT) AS HourID

	UNION ALL 

	SELECT HourID + 1
	FROM TimeSequence
	WHERE HourID < 23

)
INSERT INTO Time_Dim(HourID)
SELECT HourID
FROM TimeSequence
OPTION (MAXRECURSION 200);


UPDATE Time_Dim
SET AmPm = 
	CASE
		WHEN HourID BETWEEN 0 AND 11 THEN 'AM'
		ELSE 'PM'
	END,
DayPeriod = 
	CASE
		WHEN HourID BETWEEN 5 AND 9 THEN 'Morning'
		WHEN HourID BETWEEN 10 AND 14 THEN 'Midday'
		WHEN HourID BETWEEN  15 AND 19 THEN 'Afternoon'
		ELSE 'Night'
	END,
FormattedHour = 
	CASE
		WHEN HourID = 0 THEN 12
		WHEN HourID > 12 THEN HourID - 12 
		ELSE HourID
	END
FROM Time_Dim;

-- Hour Dimension Preview
SELECT HourID, FormattedHour, AmPm, DayPeriod
FROM Time_Dim;


-- Live Alerts Fact

INSERT INTO Live_Alerts_Fact(DateID, HourID, SystemwideRouteID, TrainRouteID, BusRouteID, RouteStatus, Time)
SELECT
	FetchedDate,
	DATEPART(HOUR, FetchedTime),
	CASE
		WHEN RecordType = 'Systemwide' THEN RouteID
		ELSE NULL
	END,
    CASE
		WHEN RecordType = 'Rail' THEN RouteID
		ELSE NULL
	END,
    CASE
		WHEN RecordType = 'Bus' THEN RouteID
		ELSE NULL
	END,
    RouteStatus,
	FetchedTime
FROM Master_Alerts AS m
WHERE NOT EXISTS (
	SELECT 1
	FROM Live_Alerts_Fact AS a
	WHERE a.DateID = m.FetchedDate 
	AND a.Time = m.FetchedTime
	AND ISNULL(a.BusRouteID, -1) = 
		ISNULL(
			CASE WHEN m.RecordType='Bus' THEN m.RouteID
			END, -1)
    AND ISNULL(a.TrainRouteID, -1) = 
		ISNULL(
			CASE WHEN m.RecordType = 'Rail' THEN m.RouteID END,
			-1)
    AND ISNULL(a.SystemwideRouteID, -1) = 
		ISNULL(
			CASE WHEN m.RecordType='Systemwide' THEN m.RouteID
			END, -1)
	);

-- Live Alerts Fact Preview
SELECT
	AlertID,
	DateID, HourID, SystemwideRouteID, TrainRouteID, BusRouteID,
	RouteStatus, Time, AlertSeverityRange, RouteStatusCategory
FROM Live_Alerts_Fact;

-- vw_Historical_Alerts is a view built directly on top of Live_Alerts_Fact (filtered to a date range), not a separate fact table with its own load process.
-- vw_Historical_Alerts is used for historical trend analysis over the selected date range.

-- Historical Alert Fact View Preview
SELECT
	AlertID,
	DateID, HourID, SystemwideRouteID, TrainRouteID, BusRouteID,
	RouteStatus, Time, AlertSeverityRange, RouteStatusCategory
FROM vw_Historical_Alerts;

-- Historical Calendar Dimension View Preview
SELECT
	DateID, Year, Quarter,
	MonthName, MonthShortForm, MonthNumber,
	WeekNumber, Weekday, WeekdayShortForm
FROM vw_Historical_Calendar;






