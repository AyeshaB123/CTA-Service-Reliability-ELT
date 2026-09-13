# Chicago Transit Authority (CTA) Service Reliability Monitoring & Analysis

> API Data Ingestion | Python | ELT | SQL | Automated Pipeline | Power BI

## 📌 Project Overview

This project analyzes CTA bus and train service reliability using live and historical alert data, examining patterns at two levels: what’s happening right now, and what the past data shows.

It provides a real-time view of current status across all routes, including a persistence analysis that flags routes stuck in an unchanged status for at least 1 hour. An 8-day historical view uncovers patterns in delays, disruptions, and affected routes. Furthermore, it investigates trends across the three services - Bus, Train, and Systemwide, by highlighting peak hours, day periods, and weekday patterns.

The project concludes with recommendations connecting the findings to CTA’s stated goals and financial constraints as outlined in its FY2026 Report.

---

## 📁 Project Deliverables
> **Note:** All deliverables except Real Pipeline Material are samples shared for testing and review, giving a glimpse of my process rather than the complete project. The "Real Pipeline Material" folder contains the actual production files: Python scripts and the final dashboard PDF only. All other folders (sample dataset, Power BI, SQL) are for testing purposes that are similar to my real work.

- [Dashboard](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/blob/main/02_PowerBI/Service%20Reliability%20Dashboard.pdf)
- [Documentation](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/01_Documentation)
- [SQL Server Scripts](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/04_SQL)
- [Real Pipeline Material](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/05_RealPipelineMaterial)
- [Jira](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/blob/main/06_Jira/Jira%20Dashboard%20Preview.pdf)
- [Sample Dataset](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/03_SampleData)

---

## 🎯Main KPIs

| KPI | Value |
|---|---:|
| System Health |    60.7%    |
| Disruption Rate | **39.3%** |
| Overall Delay Rate | **1.9%** |
| Bus Delay Rate | **2.0%** |
| Train Delay Rate | **0.9%** |


## 🔍 Insights

### 1. System-Level Insight

- System health: 60.7% of alerts indicate normal service.
- System delay rate: 1.9%, with 2.0% for Bus and 0.8% for Train.
- Disruption rate: 39.3%, considerably higher than the delay rate, showing that disruption alerts are not equivalent to actual delays.
- Disrupted routes: 23.2%.
- Day pattern: Sunday and Monday have the highest normal-service counts and disruptions.
- Delay pattern: Saturday and Sunday have the highest delay rates.


### 2. Disruption Insights
- The overall disruption rate is **39.3%**.

| Alert Category | % of Disruption Alerts |
|---|---:|
| Planned Reroute | 25.00% |
| Added Service | 5.63% |
| Bus Stop Note | 4.13% |
| Service Change | 1.81% |
| Bus Stop Relocation | 0.95% |
| Minor Delays / Reroute | 0.82% |


- **Planned Change** is the largest driver of disruption alerts, indicating that most disruptions are known in advance rather than caused by unexpected service breakdowns.
- The following bus routes each have a **0.72% disruption rate** and collectively represent a significant share of overall disruption activity:
  - 31st/35th, 67th-69th-71st, Archer, Armitage, Austin, Blue Island/26th, Broadway, California/Dodge, Chicago, Clarendon/Michigan Express, Clark, Cottage Grove, Damen, Foster, Halsted
- Train lines including **Blue, Green, Purple, and Yellow** also show higher disruption activity.

### 3. Bus Delay Insight

- Delay rate: 2.0%, higher than Train.
- Affected routes: 29.
- Peak hour: 5 AM, with other high-delay hours between 4AM to 7AM, particularly 6PM to 7 PM.
- Day-period pattern: Afternoon has the highest delay rate; Morning is 2.1%, Midday 1.9%, and Night 1.9%.
- Highest weekday: Saturday; Saturday and Sunday show higher delay rates overall.
- Bottom 3 bus routes by delays: Blue Island/26th, Jackson 26, and Outer DuSable Shore Express.

### 4. Train Delay Insight

- Delay rate: 0.8%.
- Affected routes: 3.
- Peak hour: 16:00, with other high delay hours at 10:00 and 19:00.
- Peak day period: Afternoon.
- Highest weekday: Wednesday, followed by Monday and Thursday; Friday, Sunday, and Tuesday show 0% delay rate.
- Status distribution: Normal Service is dominant, followed by Added Service, Special Note, Service Change, and Planned Work/Partial Closure.
- Bottom 3 train lines by delays: Blue, Green, and Pink.


## 💡Recommendations

### 1. System-Level

- Disruption rates are not delays and should be tracked and communicated separately, based on severity level.
- CTA uses around 10 status categories (e.g., Normal Service, Bus Stop Note, Bus Stop Relocation, Minor Delays, Major Delays), grouped under broader types like Information Alert, Delay Alert, and Planned Route Alert.
- Surfacing this structure benefits the agency in two ways:
  - Rider-facing displays and alerts become clearer, helping customers accurately understand the situation.
  - The agency can more easily identify which problems are urgent and need immediate attention.
 
### 2. Disruption Alerts

- Optimize planned changes: If disruptions are caused by internal factors, consider spacing them out to avoid repeated disruption on the same routes.
- Improve alert transparency: Clearly indicate whether the disruption is caused by an internal or external factor so riders have better context.
- Investigate high disruption bus routes: Review higher disruption routes individually to identify contributing factors such as traffic, road conditions, construction, or operational issues.
- Apply targeted train line reviews: Conduct similar analysis for train lines with high disruption activity, prioritizing areas where disruptions affect larger numbers of riders.
- Reduce alert fatigue: Frequent alerts, even when planned, can affect the customer experience. Repeated disruptions require riders to replan their trips and may make them less likely to notice important alerts.


### 3. Bus Service

- Delays are concentrated in specific periods and routes, indicating areas for targeted investigation.
- Contributing factors worth investigating: traffic conditions, running time, bus bunching, and operator/fleet availability.
- CTA's FY2026 Budget Book identifies running-time review as part of its plan. The agency could prioritize the affected routes and periods within this review.
- This could help determine whether running-time schedules are contributing to the observed delays, and surface opportunities for targeted improvements.

### 4. Train Service

- Delays are concentrated on specific lines and time periods, indicating areas for targeted investigation.
- Contributing factors worth investigating: slow zones, running time, and other operational factors.
- CTA's FY2026 Budget Book mentions ongoing work to eliminate slow zones. The agency could prioritize the affected lines and peak periods when evaluating this work.
- This could help determine whether slow zones are contributing to the observed delays, and surface opportunities for targeted improvements.


---

## 👩‍💼 Analyst View

While working on this project, CTA's Fiscal Year 2026 report helped me understand the limitations to consider while analyzing the data and providing recommendations. The report explicitly mentions a real financial constraint: public funding has declined, and one time post pandemic federal funding is running out. Additionally, post pandemic changes, increased remote work, high inflation, and high fuel costs have put further pressure on CTA in several areas. Two that are particularly relevant to this analysis are CTA’s ability to introduce new services and its ability to address the operational problems identified in this project.

For example, the analysis found that CTA's bus delay rate and disruption alert rate are high. If further investigation shows that a lack of operators and limited fleet availability are contributing causes, CTA cannot simply invest in more fleet or hire more staff, given their limited overall budget. Given this constraint, the recommendations above are intentionally limited to actions that would not add further financial pressure on CTA.

This also changes how CTA should look at new opportunities. Instead of making a large investment immediately based on a problem or an opportunity, CTA could first test a smaller change and see what happens. For example, they could test whether a change improves reliability, increases ridership, improves customer experience, or reduces operating pressure. Based on the results, they can then decide whether the change is worth expanding and putting more resources into it. This approach allows CTA to make larger investments based on actual results rather than assumptions.

From a broader strategic perspective, improving operational efficiency and increasing internally generated revenue could also become more important when external funding is uncertain. This does not mean that CTA should focus only on revenue or reduce its public-service responsibilities. Rather, it means that CTA needs to consider the overall value of an improvement. When resources are limited, identifying opportunities that can create stronger results without requiring a large amount of additional investment becomes increasingly important.

This also helped me understand a broader industry pattern post COVID. In my view, businesses now need more cost efficient approaches than ever: solutions that require less investment while still delivering strong returns. While low investment, high return decisions have always mattered to organizations, they are now less of a preference and more of a requirement for survival and growth.

---
## Additional Technical Details

**Dashboard Details**
- 1st dashboard reads directly from the Live Latest file, showing current status and severity level for each service line.
- 2nd dashboard shows persistence status, comparing the Live Latest file against Live_Alerts_Fact to check whether a delay is ongoing or new.
- 3rd and 4th dashboards cover historical data, providing an overview along with insights into Train and Bus service line delays.


**Dataset Overview**
- Sample dataset covers 8 days of CTA alert data from Sep 22nd, 2026 to Sep 29th, 2026, collected at multiple timestamps throughout each day
- Total alerts in the complete dataset: 41,125
- Total Bus Routes: 127
- Total Train Routes: 8

**Alert Type Categories**
Each alert is classified into one of 4 categories: Normal Service, Delays, Planned Change, Information, by comparing CTA's severity level mentioned in documentation against the raw Route Status field.

**Delay Rate Calculation**
- Overall / Train / Bus: Delays ÷ all non-Normal-Service alerts
- Systemwide: Delays ÷ all Systemwide alerts (including Normal Service), since Systemwide only has two possible states (Normal Service or Delays), the standard formula would always show 100%, so total observations are used instead.
- If severity level > 0, then it's a disruption alert therefore, Route Status Category "Information" is also considered as Disruption.

**Train Route Availability**

Some train lines do not run every day, and their scheduled days/times are not part of CTA's official API documentation. This was confirmed through several third-party sources, which noted that specific train routes only operate on specific days.

This pattern is also visible in the dataset itself. For instance, a few train lines show inconsistent presence across days and was further confirmed by observing the live dashboard, where the same routes weren't always active day to day.

Therefore, the day level and hour level train metrics in this analysis reflect only the days a route was actually running. Gaps in a route's data may indicate the route was scheduled off, not a data collection failure.


**Pipeline & Approach**
- Data refreshed automatically every 15 minutes via a SQL Server Agent job
- Agile methodology and Scrum were used to manage deliverables through sprints. The project was organized into 4 sprints across 3 Epics, each with a specific purpose and deliverable, applying a realistic project workflow.

---

## 🛠️ Tools & Skills

- **Postman:** API testing
- **Python:** API data ingestion, data processing, automation
- **SQL Server:** DDL, DML, DQL, CTEs, Views, designing relationships in a galaxy schema
- **SQL Server Agent:** Automated workflow and job scheduling
- **Power BI:** DAX, semantic modeling, interactive dashboards

---
## References

- [Chicago Transit Authority FY2026 Budget Book](https://cst.brightspotcdn.com/9c/b0/c9bab8dc45b29c3a0aa9a418f543/fy2026-budget-book.pdf)
- [Chicago Transit Authority Customer Alerts API Documentation](https://www.transitchicago.com/assets/1/6/cta_Customer_Alerts_API_Developer_Guide_and_Documentation_20160929.pdf)


---

Author: Ayesha Batool

---

# 🤝 Let's Connect

- [LinkedIn](https://www.linkedin.com/in/ayesha-analyst/)
- [Email](mailto:ayesha.batool.career@gmail.com)




