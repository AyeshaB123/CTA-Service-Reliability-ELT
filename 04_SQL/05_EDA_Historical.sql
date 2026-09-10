

USE CTA;
GO

-- This script performs exploratory data analysis (EDA) on 8 days of historical alert data (vw_Historical_Alerts).
-- It looks at disruption and delay counts, then breaks them down by service type, severity level, and time to find patterns worth putting in the dashboard.


-- ****************************** EDA ******************************

-- Number of records of 8 days

SELECT COUNT(AlertID) AS "Record Count"
FROM vw_Historical_Alerts

-- Records: 41124


-- Delay Count in last 8 days
SELECT COUNT(AlertID) AS "Total Delays"
FROM vw_Historical_Alerts
WHERE RouteStatusCategory = 'Delays';

-- Total Delays (Minor/Major) were 301.
-- How these delays are divided among services, calendar, time and severity level?


-- Disruption Alerts in last 8 days
SELECT COUNT(AlertID) AS "Disruption Alerts"
FROM vw_Historical_Alerts
WHERE RouteStatusCategory <> 'Normal Service';

-- Total Disruption Alerts (that include any Non-Normal Service) includes 16151..
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
	WHERE RouteStatusCategory <> 'Normal Service'
)

SELECT
	RouteStatusCategory AS [Alert Category],
	[Total Alerts Per Status],
	CAST([Total Alerts Per Status] * 100.0 / [Total Disruptions] AS DECIMAL(6, 1)) AS [%Disruption Alerts]
FROM c_CountPerAlertType
CROSS JOIN c_TotalDisruptionAlerts
ORDER BY [%Disruption Alerts] DESC;


-- 71.4%, and 26.7% belongs to Planned Change and Information Alerts. Only 1.9% are Delays.

-- Severity Level Ranking of Disruption Alerts
WITH c_CountPerAlertType AS(
	SELECT
		RouteStatus, AlertSeverityRange AS [Severity Level],
		COUNT(AlertID) AS "Total Alerts"
	FROM vw_Historical_Alerts
	WHERE RouteStatus <> 'Normal Service'
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
ORDER BY [Total Alerts] DESC;

-- WHERE [Rank by Severity] IN (1, 2, 3);


-- ************************ LAYER 2: DELAYS ***************************

-- Delay Count in last 8 days  were 301.
-- How these delays are divided among services, calender, time and severity level?

-- Major and Minor Delay Contribution

SELECT COUNT(AlertID) AS "Count"
FROM vw_Historical_Alerts
WHERE RouteStatus IN ('Major Delays', 'Minor Delays / Reroute', 'Minor Delays');
-- Total Delays (Minor/Moajor) were 301.
-- How these delays are divided among services, calender, time and severity level?

-- Severity elvel with delays and lines
SELECT TrainRouteID, RouteStatus, RouteStatusCategory
FROM vw_Historical_Alerts
WHERE TrainRouteID IS NOT NULL
	AND RouteStatusCategory = 'Delays';

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


-- Train Delay Rate
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
-- Train Route Delay Rate is 0.2%


-- In last 8 days, there are only 3 delays occured but all of them falls in 'Major Delay' category and each it's severity level is the highest


-- Systemwide Delay Rate = Delay Count / Total Observations *** ADD THIS NOTE IN DASHBOARD
SELECT
	CAST(
		(SELECT COUNT(AlertID)
		FROM vw_Historical_Alerts
		WHERE SystemwideRouteID IS NOT NULL
		AND RouteStatusCategory = 'Delays'
		) * 100.0 / COUNT(AlertID) AS DECIMAL(6, 1)
		) AS "Systemwide Delay Rate"
FROM vw_Historical_Alerts
WHERE SystemwideRouteID IS NOT NULL;
-- Systemwide rate is 0.0%


SELECT RouteStatusCategory, COUNT(AlertID) AS [Count]
FROM vw_Historical_Alerts
WHERE SystemwideRouteID IS NOT NULL
GROUP BY RouteStatusCategory;

-- Alert Type are either Planned Change or Normal Service



-- Breaking down Bus Delay Rate further

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
ORDER BY [Delay Rate] DESC;




