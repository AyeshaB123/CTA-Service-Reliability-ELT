# Chicago Transit Authority (CTA) Service Reliability Monitoring & Analysis

### API Data Ingestion | Python | ELT | SQL | Automated Pipeline | Power BI

## 📌 Project Overview

This project analyzes CTA bus and train service reliability using live and historical alert data, examining patterns at two levels: what’s happening right now, and what the past data shows.

It provides a real-time view of current status across all routes, including a persistence analysis that flags routes stuck in an unchanged status for at least 1 hour. An 8-day historical view uncovers patterns in delays, disruptions, and affected routes. Furthermore, it investigates trends across the three services - Bus, Train, and Systemwide, by highlighting peak hours, day periods, and weekday patterns.

The project concludes with recommendations connecting the findings to CTA’s stated goals and financial constraints as outlined in its FY2026 Report.

## 📁 Project Deliverables
> **Note:** All deliverables except Real Pipeline Material are samples shared for testing and review, giving a glimpse of my process rather than the complete project. The "Real Pipeline Material" folder contains the actual production files: Python scripts and the final dashboard PDF only. All other folders (sample dataset, Power BI, SQL) are for testing purposes that are similar to my real work.

- [Dashboard](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/blob/main/02_PowerBI/Service%20Reliability%20Dashboard.pdf)
- [Documentation](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/blob/main/01_Documentation/Documentation.pdf)
- [SQL Server Scripts](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/04_SQL)
- [Real Pipeline Material]()
- [Jira](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/blob/main/06_Jira/Jira%20Dashboard%20Preview.pdf])
- [Sample Dataset](https://github.com/AyeshaB123/CTA-Service-Reliability-ELT/tree/main/03_SampleData)

##💡Insights & Recommendations

### 1. System-Level Insight

- **CTA's system health is 60.7%.**
- **Disruption rate is 39.3%.**
- **Delay rate is 1.9%**, with 2.0% for Bus and 0.9% for Train.

**Recommendation:** Disruption rates are not delays, so they should be tracked and communicated separately based on their severity level. Since the transit agency currently shares status information without details such as status category and severity level in rider-facing displays and alerts, displaying this information would help customers accurately understand the situation and improve their service experience.

### 2. Bus Delay Insight

- **Bus delay rate is 2.0%.**
- Peak delays occur at **5-6 AM and 6-7 PM**.
- The highest day period is **afternoon**.
- The highest-delay day is **Saturday**.
- **Bottom 3 routes by delays:** Blue Island/26th, Jackson 26, and Outer DuSable Shore Express.

**Recommendation:** Delays are concentrated in specific periods and routes, indicating areas for targeted investigation. Investigate traffic, running time, bus bunching, and operator/fleet availability.
Since CTA's FY2026 Budget Book identifies running-time review as part of its plan, the agency could prioritize the affected routes and periods in this review. This could help determine whether running-time schedules are contributing to the observed delays and identify opportunities for targeted improvements.

### 3. Train Delay Insight

- **Train delay rate is 0.8%**, with peak delays at **10 AM, 4 PM, and 7 PM**.
- The highest day period is **afternoon**.
- The highest-delay day is **Wednesday**.
- **Bottom 3 train by delays:** Blue, Green, and Pink.

**Recommendation:** Delays are concentrated on specific lines and time periods, indicating areas for targeted investigation. Investigate slow zones, running time, and other operational factors. Since CTA's FY2026 Budget Book mentions its ongoing work to eliminate slow zones, prioritize the affected lines and peak periods when evaluating this work. This could help determine whether slow zones are contributing to the observed delays and identify opportunities for targeted improvements.

### 4. Route Status Insight

- High disruption-alert volumes on certain routes may indicate recurring service issues.

**Recommendation:** Recurring alerts may have operational or external causes. Prioritize high-alert routes for root-cause analysis, and focus on reducing recurring service disruptions rather than the number of alerts reported.

## 👩‍💼 Analyst View

When I was working on this project, I went through CTA's Fiscal Year 2026 report, which helped me understand the limitations I needed to consider while analyzing the data and providing recommendations. The report explicitly mentions a real financial constraint: public funding has declined, and one-time post-pandemic federal funding is running out. Additionally, post-pandemic changes - increased remote work, high inflation, and high fuel costs - have put further pressure on CTA in two ways: it limits their ability to introduce new services, and it limits how they can address the problems this analysis identified.

For example, the analysis found that CTA's bus delay rate and disruption alert rate are high, and if further investigation showes that a lack of operators and limited fleet availability are contributing causes, CTA can't simply invest in more fleets or hire more staff, because of their limited overall budget. This is why I avoided recommendations that would conflict with this constraint. All recommendations I made are ones that would not put additional financial pressure on CTA.

This also helped me understand a broader industry pattern post-COVID. In my view, businesses now need more cost-efficient approaches than ever - solutions that require less investment while still delivering strong returns. While low-investment, high-return decisions have always mattered to organizations, they're now less of a preference and more of a requirement for survival and growth.


## 🛠️ Tools & Skills

- **Postman:** API testing
- **Python:** API data ingestion, data processing, automation
- **SQL Server:** DDL, DML, DQL, CTEs, Views, designing relationships in a galaxy schema
- **SQL Server Agent:** Automated workflow and job scheduling
- **Power BI:** DAX, semantic modeling, interactive dashboards

---

Author: Ayesha Batool

---

# 🤝 Let's Connect

- [LinkedIn](https://www.linkedin.com/in/ayesha-analyst/)
- [Email](mailto:ayesha.batool.career@gmail.com)




