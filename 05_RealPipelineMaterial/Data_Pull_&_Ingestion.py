


import requests
import json
import os
import pyodbc
from datetime import datetime


# CTA Route Status API

url = "https://www.transitchicago.com/api/1.0/routes.aspx"

route_types = ["Bus", "Rail", "Systemwide"]

# Folder setup — single "data" folder containing two files
DATA_FOLDER = r"C:\a_Final_Portfolio\CTA\alerts_raw_data"
os.makedirs(DATA_FOLDER, exist_ok=True)

LIVE_FILE = os.path.join(DATA_FOLDER, "Live_route_status.json")

cleaned_routes = []


for route_type in route_types:
    params = {"type": route_type, "outputType": "JSON"}
    response = requests.get(url, params=params)
    print(route_type, response.status_code)

    data = response.json()
    route_info = data["CTARoutes"]["RouteInfo"]

    for route in route_info:
        cleaned_routes.append({
            "RecordType": route_type,
            "RouteID": route["ServiceId"],
            "RouteName": route["Route"],
            "RouteStatus": route["RouteStatus"],
            "RouteColorCode": route["RouteColorCode"],
            "FetchedDate": datetime.now().strftime("%Y-%m-%d"),
            "FetchedTime": datetime.now().strftime("%H:%M:%S")
        })

print(f"Total routes collected: {len(cleaned_routes)}")

# Live file — always overwritten with only the most recent pull
with open(LIVE_FILE, "w", encoding="utf-8") as f:
    json.dump(cleaned_routes, f, indent=4)

timestamp_str = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
historical_filepath = os.path.join(DATA_FOLDER, f"Historical_route_status_{timestamp_str}.json")

with open(historical_filepath, "w", encoding="utf-8") as f:
    json.dump(cleaned_routes, f, indent=4)

print(f"Live saved to: {LIVE_FILE}")
print(f"Historical saved to: {historical_filepath}")


# Loading data to SQL Server


# Connect to SQL Server and insert this run's data
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=DESKTOP-EM83E04;"
    "DATABASE=CTA_DB;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

# Clear the live table before inserting fresh data
cursor.execute("TRUNCATE TABLE Live_Latest_Alerts")


for route in cleaned_routes:
    cursor.execute(
        """
        INSERT INTO Live_Latest_Alerts (RecordType, RouteID, RouteName, RouteStatus, RouteColorCode, FetchedDate, FetchedTime)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        route["RecordType"],
        route["RouteID"],
        route["RouteName"],
        route["RouteStatus"],
        route["RouteColorCode"],
        route["FetchedDate"],
        route["FetchedTime"]
    )


for route in cleaned_routes:
    cursor.execute(
        """
        INSERT INTO Master_Alerts (RecordType, RouteID, RouteName, RouteStatus, RouteColorCode, FetchedDate, FetchedTime)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        route["RecordType"],
        route["RouteID"],
        route["RouteName"],
        route["RouteStatus"],
        route["RouteColorCode"],
        route["FetchedDate"],
        route["FetchedTime"]
    )

conn.commit()
cursor.close()
conn.close()

print(f"Inserted {len(cleaned_routes)} rows into SQL Server")











