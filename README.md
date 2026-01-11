# 📊 Enterprise Sales Analytics & Executive Dashboards  
**SQL Server → Power BI | End-to-End Business Intelligence Project**

---

## 🚀 Project Snapshot (30-Second Overview)

This project delivers a **full enterprise sales analytics workflow**, built on a real data warehouse and translated into executive-ready dashboards.

- Built a structured **SQL analytical layer** on top of a normalized data warehouse  
- Performed **exploratory and deep-dive SQL analysis** for business insights  
- Designed **multi-page Power BI dashboards** for executives and stakeholders  
- Delivered clear, actionable **business intelligence outputs**

**Tools:** SQL Server (T-SQL), Power BI  
**Focus Areas:** Business analytics, KPI analysis, customer insights, product performance, executive reporting

---

## 🔗 Live Power BI Dashboard

👉 **View the interactive dashboard here:**  
https://app.powerbi.com/view?r=eyJrIjoiOTQyZjY3YTYtNjZjNC00ZmM4LThiY2QtNjhiYmI0M2ExZTBmIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9

*(Public view — no login required)*

---

## 🧠 Project Story — Why This Project Exists

Sales data is often available, but **actionable insight is not**.

Executives need clear answers to questions such as:
- Where does revenue really come from?
- Which products and customers drive profit — not just sales?
- Are we overly dependent on a small group of customers?
- Which segments or products deserve more investment?

This project bridges the gap between **raw transactional data** and **business decision-making** by simulating a real enterprise analytics workflow.

---

## 📊 Dataset Description

- **Source:** AdventureWorks Data Warehouse  
- **Database Version:** AdventureWorksDW2019  
- **Dataset Type:** Transactional sales data (fact + dimensions)  
- **Primary Analytical View:** `vw_Sales_Analysis`

**Important Note:**  
While the database schema is labeled **DW2019**, the **actual sales data spans from 2021 to 2025**, based on the Date dimension.  
This enables realistic time-series, trend, and seasonality analysis.

---

## 🛠️ Project Workflow

### 1️⃣ Data Familiarization & Validation (SQL)

Initial exploration of the raw warehouse tables was performed to:
- Understand the data model and relationships  
- Validate row counts and data completeness  
- Confirm the sales date range  
- Perform data sanity checks across core tables  

This reflects how analysts work in real production environments before building reporting layers.

---

### 2️⃣ Analytical View Construction (SQL)

**Core Output:** `vw_Sales_Analysis`

Rather than querying many large normalized tables repeatedly, a consolidated analytical view was created by joining:

- `FactInternetSales`
- `DimCustomer`
- `DimProduct`
- `DimDate`

The view includes:
- Order identifiers  
- Time dimensions (year, month, quarter, weekday)  
- Customer attributes  
- Product attributes  
- Sales, cost, and profit measures  
- Derived metrics such as **Gross Profit**

This view serves as a **single source of truth** for analysis and reporting.

---

### 3️⃣ Exploratory Data Analysis (SQL)

**File:** `IntrnetSales_eda.sql`

After building the analytical view, EDA was performed focusing on:
- Sales and profit distributions  
- Time-based trends  
- Customer purchasing behavior  
- Product and category performance  
- Data quality and missing values  

Using the analytical view simplified queries and enabled deeper, cleaner analysis.

---

### 4️⃣ Deep-Dive Business Analysis (SQL)

**File:** `InternetSales_sql_deep_dive.sql`

Advanced SQL analysis included:
- Top and bottom products by sales and profit  
- Customer order frequency analysis  
- Segment contribution to revenue and profit  
- Revenue concentration and distribution patterns  
- Business-focused aggregations beyond basic summaries  

This phase moves the project from descriptive analytics toward **decision-support insights**.

---

### 5️⃣ Power BI Dashboards

**File:** `IntrnetSales_dashboard.pbix`

Insights were translated into interactive dashboards designed for executive consumption.

**Dashboards include:**

**Executive Summary**
- Total sales, profit, margin, customers, and orders  
- Sales and profit trends over time  
- Geographic sales distribution  
- One-page executive overview  

**Product Performance**
- Top and bottom products by sales and profit  
- Product line contribution analysis  
- Revenue vs profitability comparison  
- Identification of high-revenue, low-margin products  

**Customer Insight**
- Top and bottom customers by sales and profit  
- Order frequency distribution  
- Customer contribution by segment  
- Identification of high-value and low-engagement customers  

Each dashboard prioritizes **clarity, business relevance, and executive usability**.

---

## 📁 Project Structure

enterprise-sales-analytics-sql-powerbi/
│
├── IntrnetSales_eda.sql
├── InternetSales_sql_deep_dive.sql
├── IntrnetSales_dashboard.pbix
│
├── executive_summary.png
├── product_performance.png
├── customer_insight.png
│
└── README.md


---

## 🧠 Key Outcomes

- Built an analytical layer from a normalized enterprise data warehouse  
- Demonstrated real-world SQL analytics workflows  
- Delivered executive-ready Power BI dashboards  
- Connected transactional data to strategic business questions  
- Produced portfolio-level, recruiter-ready BI assets  

---

## 🚀 Skills Demonstrated

- SQL Server (T-SQL)  
- Data warehouse concepts (fact & dimensions)  
- Analytical view design  
- Exploratory & advanced SQL analysis  
- Business KPI development  
- Power BI dashboarding  
- Executive data storytelling  

---

## 📌 Final Note

This project demonstrates how **enterprise analytics is actually done** —  
from raw warehouse tables to clean insights and executive decision support.


