

USE CTA;
GO


-- This script is written to explore the Live Data and get the insights.


-- ************************ LIVE DATA ******************************

-- Disrupted Alerts
SELECT COUNT(RecordID) AS "Disruption Alerts"
FROM Live_Latest_Alerts
WHERE RouteStatus <> 'Normal Service'; 

-- Disruption Alerts by Alert Category Type
WITH AlertCategory AS(
	SELECT
		CASE
			WHEN RouteStatusCategory = 'Normal Service' THEN 'Normal Service'
			ELSE 'Alerts'
		END AS "Alert Category"
	FROM Live_Latest_Alerts
	)

SELECT
	[Alert Category], COUNT([Alert Category]) AS "Disruption Count"
FROM AlertCategory
GROUP BY [Alert Category]
ORDER BY [Disruption Count] DESC;


-- Disruption Alerts & Disruption Rate: Train | Bus | Systemwide

WITH Route_Count_Per_Service AS(
	SELECT RecordType, COUNT(RouteID) AS "Route Count"
	FROM Live_Latest_Alerts
	GROUP BY RecordType
)

SELECT
	l.RecordType AS "Service",
	COUNT(l.RouteID) AS "Total Disruptions",
	CAST(
		COUNT(l.RouteID) * 100.0 / r.[Route Count] AS DECIMAL (6, 1)
		) AS "Disruption Rate"
FROM Live_Latest_Alerts AS l
INNER JOIN Route_Count_Per_Service AS r
	ON l.RecordType = r.RecordType
WHERE RouteStatus <> 'Normal Service'
GROUP BY l.RecordType, r.[Route Count]
ORDER BY [Disruption Rate] DESC;


-- Active Alerts by Service Type
SELECT
	RecordType AS "Service",
	RouteStatus AS "Alert Category",
	COUNT(RecordID) AS "Disruption Alerts"
FROM Live_Latest_Alerts
WHERE RouteStatus <> 'Normal Service'
GROUP BY RecordType, RouteStatus
ORDER BY [Service], [Disruption Alerts] DESC;

-- Overall Delay Rate
SELECT 
	CAST(
	(
	SELECT COUNT(RecordID)
	FROM Live_Latest_Alerts
	WHERE RouteStatusCategory = 'Delays') * 100.0/ COUNT(RecordID) AS DECIMAL(6, 1)) AS "Delay Rate"
FROM Live_Latest_Alerts
WHERE RouteStatusCategory <> 'Normal Service';


-- Delay Rate | Delay Rate Contribution : Bus | Train | Systemwide

WITH Overall_Delay_Count AS(
	SELECT COUNT(RecordID) AS [Total Delays]
	FROM Live_Latest_Alerts
	WHERE RouteStatusCategory = 'Delays'
),
ServiceTypeDelayCount AS(
		SELECT RecordType,
		SUM(
			CASE
				WHEN RouteStatusCategory = 'Delays' THEN 1
				ELSE 0
			END) AS "Delay Count"	
		FROM Live_Latest_Alerts
		GROUP BY RecordType
)
SELECT
	s.RecordType AS "Service",
	s.[Delay Count],
	o.[Total Delays],
	COALESCE(
		CAST(
		s.[Delay Count] * 100.0 / NULLIF(o.[Total Delays], 0) AS DECIMAL(6, 1)
		), 0) AS [%Delay Contribution]
FROM ServiceTypeDelayCount AS s
CROSS JOIN Overall_Delay_Count AS o;


-- Bus Route Status
SELECT
	RouteID AS 'Bus Route ID',
	RouteName AS 'Bus Route Name',
	RouteStatus AS 'Route Status',
	RouteStatusCategory AS 'Route Status Category'
FROM Live_Latest_Alerts
WHERE RecordType = 'Bus'
ORDER BY RouteStatus;

-- Train Route Status
SELECT
	RouteID AS 'Train Route',
	RouteName AS 'Train Route Name',
	RouteStatus AS 'Route Status',
	RouteStatusCategory AS 'Route Status Category'
FROM Live_Latest_Alerts
WHERE RecordType = 'Rail'
ORDER BY RouteStatus;

-- Systemwide Route Status
SELECT
	RouteID AS 'Systemwide Route',
	RouteName AS 'Systemwide Route Name',
	RouteStatus AS 'Route Status',
	RouteStatusCategory AS 'Route Status Category'
FROM Live_Latest_Alerts
WHERE RecordType = 'Systemwide'
ORDER BY RouteStatus;





