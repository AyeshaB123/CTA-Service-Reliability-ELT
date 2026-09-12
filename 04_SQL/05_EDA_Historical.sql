

USE CTA;
GO

-- This script performs exploratory data analysis (EDA) on 8 days of historical alert data (vw_Historical_Alerts).
-- It looks at disruption and delay counts, then breaks them down by service type, severity level, and time to find patterns worth putting in the dashboard.


-- ****************************** EDA ******************************

-- Number of records of 8 days

SELECT FORMAT(COUNT(AlertID), '#,##0') AS "Record Count"
FROM vw_Historical_Alerts

-- Records: 41,124


-- Delay Count in last 8 days
SELECT COUNT(AlertID) AS "Total Delays"
FROM vw_Historical_Alerts
WHERE RouteStatusCategory = 'Delays';

-- Total Delays (Minor/Major) were 308.
-- How these delays are divided among services, calendar, time and severity level?


-- Disruption Alerts in last 8 days
SELECT FORMAT(COUNT(AlertID), '#,##0') AS "Disruption Alerts"
FROM vw_Historical_Alerts
WHERE RouteStatusCategory <> 'Normal Service';

-- Total Disruption Alerts (that include any Non-Normal Service) includes 11,849.
-- How these delays are divided among alert categories, calender, time and severity level?


-- ****************** LAYER 1: DISRUPTION ALERTS **********************


-- Count of Disruption Alerts Per Category
WITH c_CountPerAlertType AS(
	SELECT
		RouteStatusCategory,
		COUNT(AlertID) AS "Total Alerts Per Status"
	FROM vw_Historical_Alerts
	WHERE RouteStatusCategory <> 'Normal Service'
	GROUP BY RouteStatusCategory
),
c_TotalDisruptionAlerts AS(
	SELECT COUNT(AlertID) AS "Total Disruptions"
	FROM vw_Historical_Alerts
)

SELECT
	RouteStatusCategory AS [Alert Category],
	FORMAT([Total Alerts Per Status], '#,##0') AS [Total Alerts Per Status],
	CAST([Total Alerts Per Status] * 100.0 / [Total Disruptions] AS DECIMAL(6, 1)) AS [%Disruption Alerts]
FROM c_CountPerAlertType
CROSS JOIN c_TotalDisruptionAlerts
ORDER BY [%Disruption Alerts] DESC;

-- %Disruption Alerts: Planned Change is 28.1% | Information is 10.5% | Delays are 0.7%


-- Severity Level Ranking of Disruption Alerts
WITH c_CountPerAlertType AS(
	SELECT
		RouteStatus, AlertSeverityRange AS [Severity Level],
		COUNT(AlertID) AS "Total Alerts"
	FROM vw_Historical_Alerts
	WHERE RouteStatusCategory <> 'Normal Service'
	GROUP BY RouteStatus, AlertSeverityRange
),
c_HighDisruptionAlertsRanking AS(
	SELECT
		RouteStatus,
		[Severity Level],
		[Total Alerts],
		CASE
			WHEN [Severity Level] = '1-19' THEN 5
			WHEN [Severity Level] = '20-39' THEN 4
			WHEN [Severity Level] = '40-59' THEN 3
			WHEN [Severity Level] = '60-79' THEN 2
			WHEN [Severity Level] = '80-99' THEN 1
		END AS "Rank by Severity"
	FROM c_CountPerAlertType
	)
SELECT
	RouteStatus AS "Route Category",
	[Severity Level],
	[Total Alerts]
FROM c_HighDisruptionAlertsRanking
ORDER BY [Total Alerts];
-- Delays total 308 alerts
-- Major Delays: 3 | Minor Delays: 7 | Minor Delays/Reroute: 298  (with severity levels ranging from 40-99)



-- ************************ LAYER 2: DELAYS ***************************


-- Major & Minor Delay Contribution

SELECT COUNT(AlertID) AS "Count"
FROM vw_Historical_Alerts
WHERE RouteStatus IN ('Major Delays', 'Minor Delays / Reroute', 'Minor Delays');

-- Total Delays (Minor/Moajor) were 308.
-- How these delays are divided among services, calender, time and severity level?


-- Since bus lines, train lines and systemwide categories are different, we use % instead of count.
-- Overall Delay Rate
SELECT
	CAST(
		(
			SELECT COUNT(AlertID)
			FROM vw_Historical_Alerts
			WHERE RouteStatusCategory = 'Delays') * 100.0 / COUNT(AlertID) AS DECIMAL(6, 1)
		) AS "Overall Delay Rate"
FROM vw_Historical_Alerts
WHERE RouteStatusCategory <> 'Normal Service';
-- Overall Delay Rate is 1.9%
-- Overall Delay Rate is low but does this stay flat across service types or changed?


-- 1. Bus Delay Rate 

SELECT
	CAST(
		(
			SELECT COUNT(AlertID)
			FROM vw_Historical_Alerts
			WHERE BusRouteID IS NOT NULL
				AND RouteStatusCategory = 'Delays'
			) * 100.0 / COUNT(AlertID) AS DECIMAL(6,1)
		) AS "Bus Delay Rate"
FROM vw_Historical_Alerts
WHERE BusRouteID IS NOT NULL
	AND RouteStatusCategory <> 'Normal Service';
-- Bus Route Delay Rate is 2.0%


-- 2. Train Delay Rate
SELECT
	CAST(
		(SELECT COUNT(AlertID)
		FROM vw_Historical_Alerts
		WHERE TrainRouteID IS NOT NULL
		AND RouteStatusCategory = 'Delays'
		) * 100.0 / COUNT(AlertID) AS DECIMAL(6,1)
		) AS "Train Delay Rate"
FROM vw_Historical_Alerts
WHERE TrainRouteID IS NOT NULL
 AND RouteStatusCategory <> 'Normal Service';
-- Train Route Delay Rate is 0.8%


-- 3. Systemwide Delay Rate
-- Systemwide Delay Rate = Delay Count / Total Observations

SELECT
	CAST(
		(
			SELECT COUNT(AlertID)
			FROM vw_Historical_Alerts
			WHERE SystemwideRouteID IS NOT NULL
				AND RouteStatusCategory = 'Delays'
			) * 100.0 / COUNT(AlertID) AS DECIMAL(6, 1)
		) AS "Systemwide Delay Rate"
FROM vw_Historical_Alerts
WHERE SystemwideRouteID IS NOT NULL;
-- Systemwide rate is 0.0%
-- Since the systemwide delay rate is 0.0%, we'll proceed with our analysis using the other service types (Train and Bus)


-- *************** Breaking down Bus Delay Rate further ****************

-- Bus Delay Rate
SELECT
	CAST(
		(
			SELECT COUNT(AlertID)
			FROM vw_Historical_Alerts
			WHERE BusRouteID IS NOT NULL
				AND RouteStatusCategory = 'Delays'
			) * 100.0 / COUNT(AlertID) AS DECIMAL(6,1)
		) AS "Bus Delay Rate"
FROM vw_Historical_Alerts
WHERE BusRouteID IS NOT NULL
	AND RouteStatusCategory <> 'Normal Service';
-- Bus Route Delay Rate is 2.0%


-- Hourly Delay Rate
WITH c_HourlyDelays AS(
	SELECT HourID, COUNT(AlertID) AS [Count]
	FROM vw_Historical_Alerts
	WHERE BusRouteID IS NOT NULL
		AND RouteStatus IN ('Minor Delays / Reroute', 'Major Delays')
	GROUP BY HourID
)

SELECT v.HourID, CAST(c.[Count] * 100.0 / COUNT(AlertID) AS DECIMAL(6, 1)) AS [Delay Rate]
FROM vw_Historical_Alerts AS v
JOIN c_HourlyDelays AS c
	ON v.HourID = c.HourID
WHERE v.BusRouteID IS NOT NULL
	AND v.RouteStatus <> 'Normal Service'
GROUP BY v.HourID, c.[Count]
ORDER BY [Delay Rate] DESC; 

-- Delay Rate spike in the early morning at 5AM and 6AM and evening at 6PM.


-- Delay Summary by Bus Route
WITH c_BusRouteDelays AS(
	SELECT BusRouteID, COUNT(AlertID) AS [Delays]
	FROM vw_Historical_Alerts
	WHERE BusRouteID IS NOT NULL
		AND RouteStatus IN ('Minor Delays / Reroute', 'Major Delays')
	GROUP BY BusRouteID
)

SELECT 
    v.BusRouteID, 
    c.[Delays], 
    COUNT(v.AlertID) AS [Total Non-Normal Records],
    CAST(c.[Delays] * 100.00 / COUNT(v.AlertID) AS DECIMAL(6, 1)) AS [Delay Rate]
FROM vw_Historical_Alerts AS v
JOIN c_BusRouteDelays AS c
	ON v.BusRouteID = c.BusRouteID
WHERE v.BusRouteID IS NOT NULL
	AND v.RouteStatus <> 'Normal Service'
GROUP BY v.BusRouteID, c.[Delays]
ORDER BY Delays DESC;


-- **************** Breaking down Train Delay Rate further *****************



-- Train Delay Rate
SELECT
	CAST(
		(
			SELECT COUNT(AlertID)
			FROM vw_Historical_Alerts
			WHERE TrainRouteID IS NOT NULL
				AND RouteStatusCategory = 'Delays'
			) * 100.0 / COUNT(AlertID) AS DECIMAL(6,1)
		) AS "Train Delay Rate"
FROM vw_Historical_Alerts
WHERE TrainRouteID IS NOT NULL
	AND RouteStatusCategory <> 'Normal Service';
-- Bus Route Delay Rate is 0.8%


-- Hourly Delay Rate
WITH c_HourlyDelays AS(
	SELECT HourID, COUNT(AlertID) AS [Count]
	FROM vw_Historical_Alerts
	WHERE TrainRouteID IS NOT NULL
		AND RouteStatusCategory = 'Delays'
	GROUP BY HourID
)

SELECT v.HourID, CAST(c.[Count] * 100.0 / COUNT(AlertID) AS DECIMAL(6, 1)) AS [Delay Rate]
FROM vw_Historical_Alerts AS v
JOIN c_HourlyDelays AS c
	ON v.HourID = c.HourID
WHERE v.TrainRouteID IS NOT NULL
	AND v.RouteStatus <> 'Normal Service'
GROUP BY v.HourID, c.[Count]
ORDER BY [Delay Rate] DESC; 
-- Delay Rate spike in the evening at 4PM, 7PM, and 10AM.

-- Delay Rate Summary
WITH c_BusRouteDelays AS(
	SELECT TrainRouteID, COUNT(AlertID) AS [Delays]
	FROM vw_Historical_Alerts
	WHERE TrainRouteID IS NOT NULL
		AND RouteStatusCategory = 'Delays'
	GROUP BY TrainRouteID
)

SELECT 
    v.TrainRouteID, 
    c.[Delays], 
    COUNT(v.AlertID) AS [Total Non-Normal Records],
    CAST(c.[Delays] * 100.00 / COUNT(v.AlertID) AS DECIMAL(6, 1)) AS [Delay Rate]
FROM vw_Historical_Alerts AS v
JOIN c_BusRouteDelays AS c
	ON v.TrainRouteID = c.TrainRouteID
WHERE v.TrainRouteID IS NOT NULL
	AND v.RouteStatus <> 'Normal Service'
GROUP BY v.TrainRouteID, c.[Delays]
ORDER BY Delays DESC;


