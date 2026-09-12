

USE CTA;
GO

-- The purpose of this script is to load data into 2 tables - Master_Alerts and Live_Latest_Alerts. The source CSV files for both are located in the "Sample Dataset" folder.
-- Download the datasets and update the file paths below to match where you saved them.


-- Load data in Master Alerts table
BULK INSERT Master_Alerts

-- IMPORTANT NOTE:
-- Update the file path below to match where "MasterAlerts.csv" is saved on your machine (see "Sample Dataset" folder).

FROM 'C:\a_Final_Portfolio\CTA\GitHubContent\03_SampleData\MasterAlerts.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '0x0a',
	CODEPAGE = '65001'
);


-- Load data in Live Latest Alerts table
-- Using a staging table here because Live_Latest_Alerts has computed columns, and BULK INSERT can't load directly into a table that has computed columns.
CREATE TABLE Staging_Live_Alerts (
	RecordType VARCHAR(20),
	RouteID VARCHAR(20),
	RouteName VARCHAR(150),
	RouteStatus VARCHAR(150),
	RouteColorCode VARCHAR(50),
	FetchedDate DATE,
	FetchedTime TIME(0)
);

BULK INSERT Staging_Live_Alerts

-- IMPORTANT NOTE:
-- Change the path with the "LiveLatestAlerts" file path (given in "Sample Dataset" folder.

FROM 'C:\a_Final_Portfolio\CTA\GitHubContent\03_SampleData\LiveLatestAlerts.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

INSERT INTO Live_Latest_Alerts(
	RecordType, RouteID, RouteName, RouteStatus, RouteColorCode, FetchedDate, FetchedTime)
SELECT RecordType, RouteID, RouteName, RouteStatus, RouteColorCode, FetchedDate, FetchedTime
FROM Staging_Live_Alerts;


-- Remove the Staging table
DROP TABLE Staging_Live_Alerts;
