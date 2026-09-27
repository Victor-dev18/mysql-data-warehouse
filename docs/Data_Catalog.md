# Data Catalog for Gold Layer

## Overview

The Gold Layer represents the business-ready data model of the data warehouse.

It is designed to support analytical queries, reporting, and downstream
business intelligence use cases.

The Gold layer follows a **Star Schema** consisting of:

- `gold.dim_customers` — Customer dimension
- `gold.dim_products` — Product dimension
- `gold.fact_sales` — Sales fact

In this MySQL implementation, the Gold layer is implemented using views
that integrate and transform data from the Silver layer.

---

## 1. `gold.dim_customers`

### Purpose

Stores customer information enriched with demographic and geographic
information from the CRM and ERP source systems.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `customer_key` | INT | Surrogate key uniquely identifying each customer record in the Gold dimension. |
| `customer_id` | INT | Numerical customer identifier from the CRM system. |
| `customer_number` | VARCHAR(50) | Customer business identifier used to integrate customer information across source systems. |
| `first_name` | VARCHAR(50) | Customer's first name. |
| `last_name` | VARCHAR(50) | Customer's last name. |
| `country` | VARCHAR(50) | Customer's country of residence, sourced from ERP location data. |
| `marital_status` | VARCHAR(50) | Standardized customer marital status such as `Married`, `Single`, or `n/a`. |
| `gender` | VARCHAR(50) | Standardized customer gender using CRM as the primary source with ERP as a fallback. |
| `birthdate` | DATE | Customer's date of birth from ERP demographic information. |
| `create_date` | DATE | Date on which the customer record was created in the CRM system. |

---

## 2. `gold.dim_products`

### Purpose

Provides business-ready product information enriched with product
category and subcategory information from the ERP system.

Only the current product records are included in the Gold dimension;
historical product versions are filtered out.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `product_key` | INT | Surrogate key uniquely identifying each product record in the Gold dimension. |
| `product_id` | INT | Product identifier from the CRM product system. |
| `product_number` | VARCHAR(50) | Structured product identifier used to reference the product. |
| `product_name` | VARCHAR(50) | Descriptive name of the product. |
| `category_id` | VARCHAR(50) | Derived product category identifier used to integrate CRM products with ERP product categories. |
| `category` | VARCHAR(50) | High-level product category such as `Bikes` or `Components`. |
| `subcategory` | VARCHAR(50) | More detailed classification of the product within its category. |
| `maintenance` | VARCHAR(50) | Indicates whether maintenance is required, such as `Yes` or `No`. |
| `cost` | INT | Product cost in whole currency units. |
| `product_line` | VARCHAR(50) | Standardized product line such as `Road`, `Mountain`, `Touring`, or `Other Sales`. |
| `start_date` | DATE | Date on which the product version became available. |

---

## 3. `gold.fact_sales`

### Purpose

Stores transactional sales data used for sales analysis and reporting.

Each record represents a sales transaction line containing the order,
product, customer, dates, quantity, price, and sales amount.

### Columns

| Column Name | Data Type | Description |
|---|---|---|
| `order_number` | VARCHAR(50) | Sales order identifier. Multiple records may exist for the same order because the source data contains multiple sales lines per order. |
| `product_key` | INT | Surrogate key linking the sales record to `gold.dim_products`. |
| `customer_key` | INT | Surrogate key linking the sales record to `gold.dim_customers`. |
| `order_date` | DATE | Date on which the sales order was placed. |
| `shipping_date` | DATE | Date on which the order was shipped. |
| `due_date` | DATE | Date on which the order was due. |
| `sales_amount` | INT | Sales amount for the sales line in whole currency units. |
| `quantity` | INT | Number of units of the product ordered in the sales line. |
| `price` | INT | Unit price of the product in whole currency units. |

---

## Gold Layer Relationships

The Gold layer follows a Star Schema:

```text
                 gold.dim_customers
                        |
                        |
                  customer_key
                        |
                        v
                 gold.fact_sales
                        ^
                        |
                   product_key
                        |
                        |
                  gold.dim_products
