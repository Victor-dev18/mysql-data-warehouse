# MySQL Data Warehouse — Project Requirements

## 1. Project Overview

This project is an independent MySQL implementation of a data warehouse inspired by the Data With Baraa SQL Data Warehouse Project.

The project uses CRM and ERP source datasets to demonstrate the end-to-end process of building an analytical data warehouse using a Medallion Architecture:

- Bronze
- Silver
- Gold

The implementation, SQL syntax, validation procedures, documentation, and database design are adapted specifically for MySQL.

---

## 2. Business Objective

The objective of this project is to build a centralized MySQL data warehouse that integrates data from CRM and ERP source systems into a clean, standardized, validated, and business-ready analytical environment.

The warehouse should provide analysts and business users with reliable data for:

- Sales analysis
- Customer analysis
- Product analysis
- Reporting
- Business intelligence
- Analytical decision support

The warehouse should transform raw source data into an organized analytical model while maintaining traceability back to the original source data.

---

## 3. Source Systems

The project uses data from two source systems:

### 3.1 CRM

The CRM source system provides:

- Customer information
- Product information
- Sales transaction information

CRM datasets:

| Dataset | Description |
|---|---|
| `cust_info.csv` | Customer information |
| `prd_info.csv` | Product information |
| `sales_details.csv` | Sales transactions |

### 3.2 ERP

The ERP source system provides additional information that complements the CRM data:

- Customer demographics
- Customer location
- Product categories

ERP datasets:

| Dataset | Description |
|---|---|
| `CUST_AZ12.csv` | Customer demographic information |
| `LOC_A101.csv` | Customer location information |
| `PX_CAT_G1V2.csv` | Product category information |

---

## 4. Data Warehouse Scope

The warehouse will integrate the available CRM and ERP datasets into a centralized analytical environment.

The project includes:

- Source data ingestion
- Bronze layer development
- Silver layer development
- Gold layer development
- Data cleansing
- Data standardization
- Data integration
- Data quality validation
- Dimensional modeling
- SQL-based analytics
- Power BI reporting
- Technical documentation
- Git version control

The initial project will focus on batch processing of the provided CSV datasets.

Real-time streaming, cloud deployment, production orchestration, and machine-learning pipelines are outside the scope of the initial implementation.

---

## 5. Data Warehouse Architecture

The project follows a Medallion Architecture consisting of three layers.

### 5.1 Bronze Layer

The Bronze layer stores raw source data with minimal or no transformation.

Responsibilities:

- Ingest source data
- Preserve source structure
- Maintain source traceability
- Validate data completeness
- Validate basic schema expectations

The Bronze layer is intended to provide a reliable representation of the source data for downstream processing and debugging.

---

### 5.2 Silver Layer

The Silver layer contains cleaned and standardized data prepared for integration and analytical processing.

Responsibilities include:

- Data cleansing
- Standardization
- Normalization where appropriate
- Data type handling
- Derived columns where required
- Data integration preparation
- Resolving source-system inconsistencies
- Data quality validation

The Silver layer acts as the intermediate processing layer between raw source data and business-ready data.

---

### 5.3 Gold Layer

The Gold layer contains business-ready data designed for analytical consumption.

The initial Gold model will use a dimensional/star-schema approach containing:

- `dim_customers`
- `dim_products`
- `fact_sales`

The Gold layer should integrate relevant CRM and ERP information into these analytical business objects.

---

## 6. Expected Gold Layer

### 6.1 Customer Dimension

`gold.dim_customers`

The customer dimension will contain customer information enriched with demographic and geographic information from the available source systems.

Expected concepts include:

- Customer identifier
- Customer number
- First name
- Last name
- Country
- Marital status
- Gender
- Birthdate
- Customer creation date

---

### 6.2 Product Dimension

`gold.dim_products`

The product dimension will contain product attributes enriched with category information.

Expected concepts include:

- Product identifier
- Product number
- Product name
- Category
- Subcategory
- Maintenance requirement
- Cost
- Product line
- Start date

---

### 6.3 Sales Fact

`gold.fact_sales`

The sales fact will contain transactional sales information connected to the customer and product dimensions.

Expected concepts include:

- Order number
- Product key
- Customer key
- Order date
- Shipping date
- Due date
- Sales amount
- Quantity
- Price

The Gold-layer data catalog defines these three objects as the business-level representation of the warehouse. 

---

## 7. Analytical Model

The primary analytical model will follow a Star Schema:

                    dim_customers
                          |
                          |
                          v
                     fact_sales
                          ^
                          |
                          |
                    dim_products

The fact table will contain sales transactions, while dimension tables will provide descriptive context for analyzing those transactions.

Surrogate keys will be used for dimension tables where appropriate.

---

## 8. Data Quality Requirements

Data quality checks will be performed throughout the warehouse development process.

The project will validate areas including:

### Bronze

- Source file completeness
- Row counts
- Column/schema consistency
- Successful data ingestion
- Unexpected missing source data

### Silver

- Null values
- Duplicate records
- Invalid values
- Invalid dates
- Data type consistency
- Standardized values
- Data cleansing results
- Source-to-target record consistency

### Gold

- Dimension uniqueness
- Fact-to-dimension relationships
- Referential integrity
- Successful CRM/ERP integration
- Business-rule validation
- Expected fact records
- Measures and derived values

Validation results will be documented where appropriate.

---

## 9. Technology Stack

| Area | Technology |
|---|---|
| Source format | CSV |
| Database | MySQL |
| Database client | MySQL Workbench |
| Architecture | Medallion Architecture |
| Data model | Star Schema |
| Diagramming | draw.io |
| Version control | Git |
| Repository | GitHub |
| Documentation | Markdown |
| Analytics | SQL |
| Visualization | Power BI |

---

## 10. Development Methodology

Each warehouse layer will follow a structured engineering workflow:

1. Analyse
2. Code
3. Validate
4. Document
5. Version

### Bronze

Analyse source systems and datasets → implement ingestion → validate completeness/schema → document → commit to Git.

### Silver

Explore and understand source data → implement cleansing and standardization → validate correctness → document → commit to Git.

### Gold

Understand business entities → integrate data → implement the analytical model → validate integration → document → commit to Git.

This methodology is adapted from the project workflow documented in the reference material.

---

## 11. Documentation Requirements

The project will maintain technical documentation covering:

- Project requirements
- Source-system analysis
- Data architecture
- Data flow
- Data integration
- Data modeling
- ETL/ELT approach
- Naming conventions
- Data catalog
- Data quality checks
- Layer-specific implementation decisions
- Analytical queries
- Power BI reporting

Diagrams will be created independently using draw.io to demonstrate understanding of the architecture rather than copying reference diagrams directly.

---

## 12. Version Control Strategy

Git will be used to track the development of the warehouse.

Changes will be committed progressively as major project milestones are completed.

Example commit categories:

- `docs:` Documentation changes
- `feat:` New functionality or implementation
- `test:` Validation and testing
- `refactor:` Structural improvements
- `fix:` Corrections

Example commits:

```text
docs: add project requirements
docs: add source system analysis
docs: add data architecture
feat: create bronze tables
feat: implement bronze data loading
test: validate bronze data completeness
docs: document bronze layer
```
--- 

## 13. Project Assumptions

The following assumptions apply to the initial implementation:

The provided CSV files represent extracts from the CRM and ERP source systems.
The source files are treated as the initial source-of-truth inputs for this project.
The project uses batch processing rather than real-time streaming.
MySQL is the target database platform.
Source data may contain quality issues and inconsistencies that must be identified during analysis and processing.
CRM and ERP identifiers may use different formats and therefore require analysis before integration.
The Gold layer will be designed for analytical workloads rather than operational transaction processing.
Power BI will consume the business-ready Gold-layer data for reporting and visualization.

---

## 14. Project Success Criteria

The project will be considered complete when:

All six source datasets are successfully ingested.
Bronze tables preserve the source data appropriately.
Silver tables contain cleaned and standardized data.
CRM and ERP data are successfully integrated.
Gold dimensions and fact tables are implemented.
The Gold layer follows the intended analytical model.
Data quality checks are implemented and documented.
The warehouse can support meaningful analytical SQL queries.
Power BI can consume the Gold-layer data.
Architecture and data-flow documentation is complete.
The project has a clear Git history.
The complete implementation is documented in the GitHub repository.
