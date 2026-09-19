
-- THIS CODE IS WRITTEN FOR MICROSOFT SQL SERVER

-- Execute this script to create the database structure

-- This script creates a database, master table, live alerts table and galaxy schema
-- Galaxy Schema consists of:
		-- 1 fact table (Live_Alerts_Fact)
		-- 2 views (Historical_Alerts, vw_Historical_Calendar)
		-- 8 dimension tables 


-- Create database
CREATE DATABASE CTA;
GO

USE CTA;
GO

CREATE SCHEMA Staging;
GO
CREATE SCHEMA Fact;
GO
CREATE SCHEMA Dim;
GO
CREATE SCHEMA Live;
GO


-- ******** CREATE 2 TABLES IN DATABASE THAT WILL BE USED FURTHER IN SCHEMA AND ANALYSIS  **********


-- Create master table to store sample data from the "Master" file in the GitHub "Sample Dataset" folder. 
CREATE TABLE Staging.Master_Alerts(
	RecordID INT IDENTITY(1, 1) PRIMARY KEY,
	RecordType VARCHAR(20),
	RouteID VARCHAR(20),
	RouteName VARCHAR(150),
	RouteStatus VARCHAR(150),
	RouteColorCode VARCHAR(50),
	FetchedDate DATE,
	FetchedTime TIME(0)
	)

-- Create live alerts table to store latest alerts sample data from the "Live Latest" file in the GitHub "Sample Dataset" folder. 
CREATE TABLE Live.Live_Latest_Alerts(
	RecordID INT IDENTITY(1, 1) PRIMARY KEY,
	RecordType VARCHAR(20),
	RouteID VARCHAR(20),
	RouteName VARCHAR(150),
	RouteStatus VARCHAR(150),
	RouteColorCode VARCHAR(50),
	FetchedDate DATE,
	FetchedTime TIME(0)
	)



-- ******** CREATE DIMENSION TABLES, FACT TABLES FOR STRUCTURING GALAXY SCHEMA ************
-- For reference, you can check the ERD in Documentation folder 


-- Train Route Dim
CREATE TABLE Dim.Train_Route_Dim(
	TrainRouteID VARCHAR(20) PRIMARY KEY,
	TrainRouteName VARCHAR(70),
	TrainColorCode VARCHAR(50)
)
-- Persistent Train Alerts Dim
CREATE TABLE Dim.Persistent_Train_Alerts_Dim(
	TrainRouteID VARCHAR(20) PRIMARY KEY,
	TrainRouteName VARCHAR(150),
	RouteStatus VARCHAR(50),
	PersistentStatusCategory NVARCHAR(50),                
	SeverityLevel NVARCHAR(10),

	FOREIGN KEY (TrainRouteID) REFERENCES Dim.Train_Route_Dim(TrainRouteID) 
)


-- Bus Route Dim
CREATE TABLE Dim.Bus_Route_Dim(
	BusRouteID VARCHAR(20) PRIMARY KEY,
	BusRouteName VARCHAR(150)
)
-- Persistent Bus Alerts Dim
CREATE TABLE Dim.Persistent_Bus_Alerts_Dim(
	BusRouteID VARCHAR(20) PRIMARY KEY,
	BusRouteName VARCHAR(150),
	RouteStatus VARCHAR(50),
	PersistentStatusCategory NVARCHAR(50),                
	SeverityLevel NVARCHAR(10),

	FOREIGN KEY (BusRouteID) REFERENCES Dim.Bus_Route_Dim(BusRouteID) 

)


-- Systemwide Dim
CREATE TABLE Dim.Systemwide_Route_Dim(
	SystemwideRouteID VARCHAR(20) PRIMARY KEY,
	SystemwideRouteName VARCHAR(150)
)
-- Persistent Systemwide Alerts Dim
CREATE TABLE Dim.Persistent_Systemwide_Alerts_Dim(
	SystemwideRouteID VARCHAR(20) PRIMARY KEY,
	SystemwideRouteName VARCHAR(150),
	RouteStatus VARCHAR(50),
	PersistentStatusCategory NVARCHAR(50),                
	SeverityLevel NVARCHAR(10),

	FOREIGN KEY (SystemwideRouteID) REFERENCES Dim.Systemwide_Route_Dim(SystemwideRouteID) 
)


-- Calendar Dim
CREATE TABLE Dim.Calendar_Dim(
	DateID DATE PRIMARY KEY,
	Year INT,
	Quarter INT,
	MonthName VARCHAR(20),
	MonthShortForm VARCHAR(20),
	MonthNumber INT,
	WeekNumber INT,
	Weekday VARCHAR(20),
	WeekdayShortForm VARCHAR(20)
)



-- Time Dim
CREATE TABLE Dim.Time_Dim(
	HourID INT PRIMARY KEY,
	FormattedHour INT,
	AmPm VARCHAR(10),
	DayPeriod VARCHAR(20)
)

-- Live Alerts Fact table (includes all alerts)
CREATE TABLE Fact.Live_Alerts_Fact(
	AlertID INT IDENTITY(1, 1) PRIMARY KEY,
	DateID DATE,
	HourID INT,
	SystemwideRouteID VARCHAR(20),
	TrainRouteID VARCHAR(20),
	BusRouteID VARCHAR(20),
	RouteStatus VARCHAR(50),
	Time TIME(0),

	FOREIGN KEY (DateID) REFERENCES Dim.Calendar_Dim(DateID),
	FOREIGN KEY (HourID) REFERENCES Dim.Time_Dim(HourID),
	FOREIGN KEY (BusRouteID) REFERENCES Dim.Bus_Route_Dim(BusRouteID),
	FOREIGN KEY (TrainRouteID) REFERENCES Dim.Train_Route_Dim(TrainRouteID),
	FOREIGN KEY (SystemwideRouteID) REFERENCES Dim.Systemwide_Route_Dim(SystemwideRouteID)

)
GO



-- View 1: Historical Alerts Fact
CREATE VIEW Fact.vw_Historical_Alerts AS
	SELECT 
		AlertID, DateID, HourID, SystemwideRouteID, TrainRouteID, BusRouteID,
		RouteStatus, Time,
		CASE
			WHEN RouteStatus = 'Normal Service' THEN '0'
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN RouteStatus IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN RouteStatus = 'Major Delays' THEN '80-99'
			ELSE '60-79'
		END AS AlertSeverityRange,
		CASE
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN 'Information'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Planned Change'
			WHEN RouteStatus IN ('Minor Delays / Reroute', 'Major Delays', 'Minor Delays') THEN 'Delays'
			WHEN RouteStatus IN ('Normal Service') THEN 'Normal Service'	
			ELSE 'Uncategorized'
		END AS RouteStatusCategory
	FROM Fact.Live_Alerts_Fact
	WHERE DateID BETWEEN '2026-08-22' AND '2026-08-29';
GO


 -- View 2: Historical Calendar Dim
CREATE VIEW Dim.vw_Historical_Calendar AS
	SELECT DateID, Year, Quarter, MonthName, MonthShortForm, MonthNumber, WeekNumber, Weekday, WeekdayShortForm
	FROM Dim.Calendar_Dim
	WHERE DateID BETWEEN '2026-08-22' AND '2026-08-29';
GO

-- View 3: Live Alerts Fact View (for Calculated Columns)

CREATE VIEW Fact.vw_Live_Alerts_Fact AS
	SELECT
		AlertID, DateID, HourID, SystemwideRouteID, TrainRouteID, BusRouteID,
		RouteStatus, Time,
		CASE
			WHEN RouteStatus = 'Normal Service' THEN '0'
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN RouteStatus IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN RouteStatus = 'Major Delays' THEN '80-99'
			ELSE '60-79'
		END AS AlertSeverityRange,
		CASE
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN 'Information'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Planned Change'
			WHEN RouteStatus IN ('Minor Delays / Reroute', 'Major Delays', 'Minor Delays') THEN 'Delays'
			WHEN RouteStatus IN ('Normal Service') THEN 'Normal Service'	
			ELSE 'Uncategorized'
		END AS RouteStatusCategory		
	FROM Fact.Live_Alerts_Fact
GO


-- View 4: Live Latest Alerts & Adding 2 columns - AlertSeverityRange & RouteStatusCategory

CREATE VIEW Live.vw_Live_Latest_Alerts AS
	SELECT
		RecordID, RecordType, RouteID, RouteName, RouteStatus, RouteColorCode, FetchedDate, FetchedTime,
		CASE
			WHEN RouteStatus = 'Normal Service' THEN '0'
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN '1-19'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN '20-39'
			WHEN RouteStatus IN ('Minor Delays / Reroute', 'Minor Delays') THEN '40-59'
			WHEN RouteStatus = 'Major Delays' THEN '80-99'  
			ELSE '60-79'
			END AS AlertSeverityRange,   
		CASE
			WHEN RouteStatus IN ('Added Service', 'Bus Stop Note', 'Special Note') THEN 'Information'
			WHEN RouteStatus IN ('Planned Reroute', 'Planned Work', 'Bus Stop Relocation', 'Planned Work w/Part Closure', 'Service Change') THEN 'Planned Change'
			WHEN RouteStatus IN ('Minor Delays', 'Minor Delays / Reroute', 'Major Delays') THEN 'Delays'
			WHEN RouteStatus = 'Normal Service' THEN 'Normal Service'
			ELSE 'Uncategorized'
		END AS RouteStatusCategory
	FROM Live.Live_Latest_Alerts
GO



















