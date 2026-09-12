

USE CTA;
GO


-- This script includes data validation that count rows, columns, check missing values/blanks, and understand the unique values in each column of MASTER ALERTS data.


-- ******* COUNT OF ROWS & COLUMNS *********

-- Number of rows
SELECT COUNT(RecordID) AS "Row Count"
FROM Master_Alerts;

-- Number of columns
SELECT COUNT(*) AS "Column Count"
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Master_Alerts';


-- ********* CHECK MISSING VALUES **********

-- Column: RecordType
SELECT RecordID, RecordType
FROM Master_Alerts
WHERE RecordType IS NULL;

-- Column: RouteID
SELECT RecordID, RouteID
FROM Master_Alerts
WHERE RouteID IS NULL;

-- Column: RouteName
SELECT RecordID, RouteName
FROM Master_Alerts
WHERE RouteName IS NULL;

-- Column: RouteStatus
SELECT RecordID, RouteStatus
FROM Master_Alerts
WHERE RouteStatus IS NULL;

-- Column: RouteColorCode
SELECT RecordID, RouteColorCode
FROM Master_Alerts
WHERE RouteColorCode IS NULL;

-- Column: FetchedTime
SELECT RecordID, FetchedTime
FROM Master_Alerts
WHERE FetchedTime IS NULL;

-- Column: FetctedDate
SELECT RecordID, FetchedDate
FROM Master_Alerts
WHERE FetchedDate IS NULL;


-- ******* CHECK COLUMN VALUES ***********

-- Column: RecordType
SELECT DISTINCT RecordType 
FROM Master_Alerts;

-- Column: RouteID
SELECT DISTINCT RecordType, RouteID
FROM Master_Alerts
ORDER BY RecordType;

-- Column: RouteName
SELECT DISTINCT RecordType, RouteName
FROM Master_Alerts
ORDER BY RecordType;

-- Column: RouteStatus
SELECT DISTINCT RouteStatus
FROM Master_Alerts
ORDER BY RouteStatus;

-- Column:  RouteColorCode
SELECT DISTINCT RecordType, RouteID, RouteColorCode
FROM Master_Alerts
ORDER BY RecordType;

-- Column:  FetchedDate
SELECT DISTINCT FetchedDate
FROM Master_Alerts
ORDER BY FetchedDate DESC;

-- Column: FetchedTime
SELECT DISTINCT FetchedTime
FROM Master_Alerts
ORDER BY FetchedTime DESC;



-- This script includes data validation that count rows, columns, check missing values/blanks, and understand the unique values in each column of LIVE LATEST ALERTS data.



-- ******* COUNT OF ROWS & COLUMNS *********

-- Number of rows
SELECT COUNT(RecordID) AS "Row Count"
FROM Live_Latest_Alerts;

-- Number of columns
SELECT COUNT(*) AS "Column Count"
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Live_Latest_Alerts';


-- ********* CHECK MISSING VALUES **********

-- Column: RecordType
SELECT RecordID, RecordType
FROM Live_Latest_Alerts
WHERE RecordType IS NULL;

-- Column: RouteID
SELECT RecordID, RouteID
FROM Live_Latest_Alerts
WHERE RouteID IS NULL;

-- Column: RouteName
SELECT RecordID, RouteName
FROM Live_Latest_Alerts
WHERE RouteName IS NULL;

-- Column: RouteStatus
SELECT RecordID, RouteStatus
FROM Live_Latest_Alerts
WHERE RouteStatus IS NULL;

-- Column: RouteColorCode
SELECT RecordID, RouteColorCode
FROM Live_Latest_Alerts
WHERE RouteColorCode IS NULL;

-- Column: FetchedTime
SELECT RecordID, FetchedTime
FROM Live_Latest_Alerts
WHERE FetchedTime IS NULL;

-- Column: FetctedDate
SELECT RecordID, FetchedDate
FROM Live_Latest_Alerts
WHERE FetchedDate IS NULL;

-- Column: AlertSeverityRange
SELECT RecordID, AlertSeverityRange
FROM Live_Latest_Alerts
WHERE AlertSeverityRange IS NULL;

-- Column: RouteStatusCategory
SELECT RecordID, RouteStatusCategory
FROM Live_Latest_Alerts
WHERE RouteStatusCategory IS NULL;


-- ******* CHECK COLUMN VALUES ***********

-- Column: RecordType
SELECT DISTINCT RecordType 
FROM Live_Latest_Alerts;

-- Column: RouteID
SELECT DISTINCT RecordType, RouteID
FROM Live_Latest_Alerts
ORDER BY RecordType;

-- Column: RouteName
SELECT DISTINCT RecordType, RouteName
FROM Live_Latest_Alerts
ORDER BY RecordType;

-- Column: RouteStatus
SELECT DISTINCT RouteStatus
FROM Live_Latest_Alerts
ORDER BY RouteStatus;

-- Column:  RouteColorCode
SELECT DISTINCT RecordType, RouteID, RouteColorCode
FROM Live_Latest_Alerts
ORDER BY RecordType;

-- Column:  FetchedDate
SELECT DISTINCT FetchedDate
FROM Live_Latest_Alerts
ORDER BY FetchedDate DESC;

-- Column: FetchedTime
SELECT DISTINCT FetchedTime
FROM Live_Latest_Alerts
ORDER BY FetchedTime DESC;



