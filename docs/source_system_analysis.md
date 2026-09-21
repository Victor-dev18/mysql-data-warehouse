# Source System Analysis

## 1. Overview

This document records the initial analysis of the CRM and ERP source datasets used in the MySQL Data Warehouse project.

The purpose of this analysis is to understand:

- Source systems
- Dataset structures
- Available attributes
- Initial relationships
- Identifier formats
- Data-quality observations
- Potential integration challenges

The findings in this document are based on inspection of the provided source CSV files.

---

# 2. Source Systems

The project contains data from two source systems:

1. CRM
2. ERP

## 2.1 CRM

The CRM source provides:

- Customer information
- Product information
- Sales transactions

### CRM datasets

| File | Purpose | Columns |
|---|---|---:|
| `cust_info.csv` | Customer information | 7 |
| `prd_info.csv` | Product information | 7 |
| `sales_details.csv` | Sales transactions | 9 |

---

## 2.2 ERP

The ERP source provides additional customer and product information.

### ERP datasets

| File | Purpose | Columns |
|---|---|---:|
| `CUST_AZ12.csv` | Customer demographics | 3 |
| `LOC_A101.csv` | Customer location | 2 |
| `PX_CAT_G1V2.csv` | Product categories | 4 |

---

# 3. CRM Source Analysis

## 3.1 Customer Information — `cust_info.csv`

The customer dataset contains approximately 18.5K records and the following columns:

| Column | Description |
|---|---|
| `cst_id` | Numeric customer identifier |
| `cst_key` | Customer business key |
| `cst_firstname` | Customer first name |
| `cst_lastname` | Customer last name |
| `cst_marital_status` | Customer marital status |
| `cst_gndr` | Customer gender |
| `cst_create_date` | Customer record creation date |

Example customer key:

```text
cst_id  = 11000
cst_key = AW00011000
