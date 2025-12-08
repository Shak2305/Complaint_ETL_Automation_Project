# Complaint ETL Automation Project  
End-to-End Data Pipeline: Excel → Power Query → Automated Exports → SQL Staging → RAW Table → Power BI

-------------

## Overview

This project demonstrates a complete production-style ETL pipeline for a complaint management dataset.  
It showcases how raw operational data is extracted, cleaned, transformed, validated, automated, and loaded into a SQL environment — ready for BI analytics and KPI reporting.

The goal:

**Convert messy, manual reporting into a clean, automated, repeatable data pipeline.**

This mirrors the workflows used in:  
Contact centres, financial services, regulatory reporting, MI/BI teams, and operations analytics.

-------------

## End-to-End Architecture

## Technologies Used

### 🔹 Data Transformation  
- Power Query (M)  
- Excel (cleaning, shaping)  
- Power Automate (optional)

### 🔹 Automation Layer  
- VBA scripting  
- Dynamic file path handling  
- Automated CSV extraction

### 🔹 Data Engineering / ETL  
- SQL (Snowflake-style & SQL Server concepts)  
- Staging tables  
- RAW tables  
- Incremental load logic  
- Excel date serial → SQL date conversion  
- Deduplication rules

### 🔹 Analytics  
- Power BI  
- KPI & SLA performance calculation  
- Trend & weekly reporting  
- Contact centre metrics  
- Category and complaint outcome insights

-------------

## Repository Structure

Repository Structure

01_Datasets/
• Sample complaint, Jira, and attrition datasets

02_PowerQuery/
• complaints_raw.m
• complaints_clean.m
• complaints_enriched.m
• complaints_categories_long.m
• fact_complaints.m
• dim_category.m
• dim_status.m
• dim_person.m
• jira_transformations.m

03_VBA/
• csv_export.bas

04_SQL/
• staging → stg_tbl_fact_complaints.sql
• raw → raw_tbl_fact_complaints.sql
• push → data_push_script.sql

05_PowerBI/
• dashboards.png
• data_model.png
• measures.md

-------------

## Key Components of This Project

### 1. Power Query Data Cleaning & Shaping  

Includes:

- Dynamic file path resolution using PARAM_PATH
- Externalised configuration with no hardcoded paths
- Workbook refreshes successfully on any machine without code changes
- Whitespace trimming and casing standardisation applied
- Text flags converted into boolean fields for consistent logic
- Blank strings converted into null values
- Safe data typing implemented using try … otherwise null
- Date fields validated and serial-date errors corrected
- Low-quality or invalid rows removed during processing
- Error-resilient transformations ensuring refresh stability
- Dynamic derivation of Year, Quarter, Month and Week fields
- Complaint ageing calculated for both open and closed cases
- Full SLA engine implemented for ACK, REVIEW and FINAL checkpoints
- Complaint status grouped into analytical categories
- Risk flag enrichment applied for operational reporting
- Contact-centre performance KPIs incorporated during transformation
- Fact_Complaints table built as the primary analytical fact
- Dim_Category created using long-format unpivot logic
- Dim_Status generated with surrogate keys and grouped outcomes
- Dim_Person created by merging Logged By, Owner and Closed By
- Date dimension ready for model integration
- Relationship-building merges implemented for dimension linking
- Optional fuzzy matching supported for person mapping
- Dimension tables fully deduplicated
- Transformations designed to support incremental refresh without volatility

---

### 2. VBA Automation (Daily CSV Extractor)

The VBA module:

- Refreshes all Power Query queries  
- Extracts transformed tables  
- Converts Excel serial dates to ISO (yyyy-mm-dd)  
- Saves the dataset into timestamped CSV files  
- Dynamic paths (no user-specific code)

This replicates a real-world daily feed for ingestion pipelines.

---

### 3. SQL Staging & RAW Layers

#### **Staging Table**
- No constraints  
- All VARCHAR  
- Accepts raw CSV files  
- Temporary landing zone  

#### **RAW Table**
- Fully typed  
- DATE, NUMBER, BOOLEAN conversion  
- Validated, deduplicated  
- Fit for analytics & BI models  

#### **Incremental Load Script**
- Deletes only existing rows for `LOGGED_ON = yesterday`  
- Inserts new rows from staging  
- Handles Excel date serial issues  
- Maintains `LOAD_DATE` audit column  
- Deduplicates based on CASE_ID & LOGGED_ON  

This mirrors enterprise-grade ingestion logic.

---

## Power BI Analytics Layer

This project supports:

- Complaint volume trends  
- SLA performance (ACK, REVIEW, FINAL)  
- Category-level analysis  
- Product/Channel insights  
- Owner/Agent performance  
- Goodwill & compensation cost tracking  
- Vulnerable customer metrics  

The Power BI models will be added in `/05_PowerBI/` in the coming days, ETA - 15/12/2025

---

## Purpose of This Project

This project showcases the ability to:

- Clean and transform messy operational datasets  
- Automate manual reporting workflows  
- Build structured ETL pipelines  
- Design SQL staging + raw layers  
- Build analytical datasets for BI  
- Handle real-world contact centre & complaints data  
- Replace Excel-heavy processes with automated solutions  

This portfolio demonstrates skills valuable for:

- BI Developer  
- Data Analyst  
- ETL Developer  
- Reporting Automation Consultant  
- Data Engineering Support  

----------

## Skills Demonstrated

- ETL architecture design (Bronze/Silver/Gold)
- Power Query M-language transformations
- Data standardisation & cleansing
- VBA automation for scheduled exports
- CSV → SQL ingestion pipelines
- Staging and raw-layer modelling
- Incremental load and MERGE logic
- KPI & SLA calculation frameworks
- Power BI data modelling
- Operational analytics (contact centre)


-----------


## Contact

For freelance work, automation, dashboards, or data engineering:

**Email:**  shakthikrishnan92@gmail.com
**Upwork:** *(to be added)*  
**LinkedIn:** (https://www.linkedin.com/in/shakthikrishnan/)

---