# 🪙 Azure Data Engineering Project: End-to-End Crypto Lakehouse
📚 Detailed Step-by-Step Tutorial
This repository contains the code and assets for the project. For a comprehensive, end-to-end guide on how to build this architecture from scratch—including infrastructure setup, security configuration, and detailed explanations of the code—please read the accompanying article on Medium:

👉 Read the Full Tutorial on Medium: [Building an Enterprise-Grade Crypto Data Lakehouse on Azure 👈](https://medium.com/@raj.vinay2408/f916a3acaebe)

![Architectre](https://github.com/user-attachments/assets/c4938116-87cb-4c8b-b380-8533bafeebeb)


## 📋 Summary

This project is a production-grade Data Lakehouse built on Microsoft Azure, designed to ingest, process, and serve large-scale cryptocurrency trade data. The pipeline successfully processed a historical dataset of over **76 Million rows** (5.5 GB raw), transforming it into a query-ready Star Schema for BI analysis.

The architecture adheres to best practices using the **Medallion Architecture** (Bronze/Silver/Gold), **Unity Catalog** for centralized governance, and **Spark Structured Streaming** for resilient, incremental data ingestion.

### Key Achievements & Features implemented:
* **Infrastructure as Code:** Control tables and Star Schema definitions managed via SQL scripts.
* **Resilient Ingestion:** Implemented Databricks **Auto Loader** for streaming ingestion, handling schema drift and file notification automatically.
* **Enterprise Security:** Zero hardcoded access keys. Utilized **Managed Identities**, **Service Principals**, and **Azure Key Vault** enforced by **Unity Catalog**.
* **Optimized Processing:** Switched from full-load to **Incremental Upserts (MERGE)** in the Silver layer using Spark Structured Streaming triggers, reducing processing time from minutes to seconds.
* **Granular Observability:** Built a custom SQL-based logging framework integrated into Azure Data Factory to track activity-level status, record counts, and provide "Red Path" failure handling.

---

## 🛠️ Tech Stack

| Category | Technology Used |
| :--- | :--- |
| **Cloud Provider** | Microsoft Azure |
| **Orchestration** | Azure Data Factory (ADF) |
| **Processing Engine** | Azure Databricks (Spark / PySpark) |
| **Storage** | ADLS Gen2 (Data Lake), Delta Lake format |
| **Serving / DW** | Azure SQL Database |
| **Governance** | Databricks Unity Catalog |
| **Security** | Microsoft Entra ID, Azure Key Vault |

---

## 🏗️ Data Flow & Architecture Layers

The pipeline follows a linear flow orchestrated by ADF, moving data through increasingly refined layers:

### 1. Ingestion Layer (Source to Bronze)
* **Source:** Local CSV files uploaded to ADLS Landing zone via AzCopy.
* **Process:** Databricks Notebook uses **Auto Loader** to stream files incrementally.
* **Target:** `crypto_cat.bronze.sales_raw` (Delta Table). Raw data is appended with technical metadata (file path, ingestion timestamp) for lineage.

### 2. Transformation Layer (Bronze to Silver)
* **Process:** Spark Structured Streaming job with `trigger(availableNow=True)` performs a micro-batch process.
* **Logic:** Data is cleaned, filtered for valid trades, and **deduplicated** based on a composite key (Timestamp + Exchange + Volume + Price) using Delta `MERGE` operations.
* **Target:** `crypto_cat.silver.trades` (Delta Table). A trusted, clean, and partitioned dataset.

### 3. Aggregation Layer (Silver to Gold)
* **Process:** PySpark batch job aggregates the clean Silver data.
* **Logic:** Calculates business metrics like Daily **VWAP** (Volume Weighted Average Price) and Total Volume per Currency Pair and Exchange.
* **Target:** Data is modeled into a **Star Schema** (Fact/Dimensions) and pushed via **JDBC** with Service Principal authentication to the Azure SQL Data Warehouse.

### 4. Operational Layer (Logging & Control)
* Azure Data Factory manages the workflow. Before and after every Databricks notebook execution, ADF runs stored procedures against an **Azure SQL Operational Database** to log start times, end times, status, and record counts. This provides a historical audit trail and enables robust failure tracking.

---


