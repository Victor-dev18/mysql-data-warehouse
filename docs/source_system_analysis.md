````markdown
# Source System Analysis

## 1. Overview

The data warehouse integrates data from two source systems:

- **CRM (Customer Relationship Management)**
- **ERP (Enterprise Resource Planning)**

The source data is provided as CSV files. The purpose of this analysis is to understand the available source datasets, their structures, relationships, identifier formats, and data-quality considerations before designing the Bronze, Silver, and Gold layers.

The analysis is based on the provided source datasets and the project reference material.

---

## 2. Source Systems

### 2.1 CRM

The CRM source system contains information related to:

- Customers
- Products
- Sales transactions

The CRM datasets are:

| Source System | Dataset | Business Area |
|---|---|---|
| CRM | `cust_info.csv` | Customer information |
| CRM | `prd_info.csv` | Product information |
| CRM | `sales_details.csv` | Sales transactions |

### 2.2 ERP

The ERP source system contains additional information that complements the CRM data.

The ERP datasets are:

| Source System | Dataset | Business Area |
|---|---|---|
| ERP | `CUST_AZ12.csv` | Customer demographics |
| ERP | `LOC_A101.csv` | Customer location |
| ERP | `PX_CAT_G1V2.csv` | Product categories |

---

# 3. Source Dataset Inventory

## 3.1 CRM Customer Information

### File

`cust_info.csv`

### Business Purpose

Contains customer information maintained by the CRM system.

### Columns

| Column | Description |
|---|---|
| `cst_id` | Customer identifier |
| `cst_key` | Customer business key |
| `cst_firstname` | Customer first name |
| `cst_lastname` | Customer last name |
| `cst_marital_status` | Customer marital status |
| `cst_gndr` | Customer gender |
| `cst_create_date` | Customer creation date |

### Example

```text
cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date
11000,AW00011000,Jon,Yang,M,M,2025-10-06
````

### Observations

The dataset contains customer identifiers, personal attributes, and customer creation dates.

During source inspection, the following data-quality situations were observed:

- Duplicate customer IDs are present.
- Some records have missing customer IDs.
- Some customer records have missing names.
- Some records have missing marital-status values.
- Some records have missing gender values.
- Some records contain incomplete customer information.

These conditions should be preserved in the Bronze layer and investigated during Silver-layer cleansing.

---

# 4. CRM Product Information

## 4.1 File

`prd_info.csv`

### Business Purpose

Contains product information maintained by the CRM system.

### Columns

| ColumnDescription |                      |
| ----------------- | -------------------- |
| `prd_id`          | Product identifier   |
| `prd_key`         | Product business key |
| `prd_nm`          | Product name         |
| `prd_cost`        | Product cost         |
| `prd_line`        | Product line         |
| `prd_start_dt`    | Product start date   |
| `prd_end_dt`      | Product end date     |

### Example

```text
prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt
210,CO-RF-FR-R92B-58,HL Road Frame - Black- 58,,R ,2003-07-01,
```

### Observations

The product dataset contains product identifiers, names, costs, product lines, and validity dates.

During source inspection, the following conditions were observed:

- Some product costs are missing.
- Some product-line values require standardization.
- Some records contain end dates while others do not.
- Multiple records can contain the same `prd_key`.
- Product dates require validation.
- Product records may represent different versions or periods for the same product key.

Because `prd_key` is not unique across the source records, it should not automatically be treated as a unique source primary key.

The product-key behavior should be investigated further during the Silver and Gold design stages.

---

# 5. CRM Sales Details

## 5.1 File

`sales_details.csv`

### Business Purpose

Contains sales transaction information from the CRM system.

### Columns

| ColumnDescription |                                              |
| ----------------- | -------------------------------------------- |
| `sls_ord_num`     | Sales order number                           |
| `sls_prd_key`     | Product key associated with the sale         |
| `sls_cust_id`     | Customer identifier associated with the sale |
| `sls_order_dt`    | Order date                                   |
| `sls_ship_dt`     | Shipping date                                |
| `sls_due_dt`      | Due date                                     |
| `sls_sales`       | Sales amount                                 |
| `sls_quantity`    | Quantity sold                                |
| `sls_price`       | Product price                                |

### Example

```text
sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price
SO43697,BK-R93R-62,21768,20101229,20110105,20110110,3578,1,3578
```

### Observations

The dataset contains transactional sales information.

A sales order can appear across multiple records with different products. Therefore, the dataset should be treated as a transaction-line-level source rather than assuming that one row represents an entire sales order.

For example, the same sales order number can occur on multiple rows.

The following relationships are expected from the source structure:

```text
sales_details.sls_cust_id
        ↓
cust_info.cst_id
```

and:

```text
sales_details.sls_prd_key
        ↓
prd_info.prd_key
```

These relationships will be validated during the data-quality and integration stages.

---

# 6. ERP Customer Demographics

## 6.1 File

`CUST_AZ12.csv`

### Business Purpose

Contains additional customer demographic information from the ERP source system.

### Columns

| ColumnDescription |                     |
| ----------------- | ------------------- |
| `CID`             | Customer identifier |
| `BDATE`           | Customer birth date |
| `GEN`             | Customer gender     |

### Example

```text
CID,BDATE,GEN
NASAW00011000,1971-10-06,Male
```

### Observations

The dataset provides demographic information that complements the CRM customer data.

The customer identifier format differs from the CRM customer key.

CRM:

```text
AW00011000
```

ERP:

```text
NASAW00011000
```

This difference in identifier format must be handled during the data integration process.

The original identifier should remain unchanged in the Bronze layer.

Standardization and integration should be performed in the Silver layer.

Some records also contain missing gender values.

---

# 7. ERP Customer Location

## 7.1 File

`LOC_A101.csv`

### Business Purpose

Contains customer country/location information from the ERP source system.

### Columns

| ColumnDescription |                     |
| ----------------- | ------------------- |
| `CID`             | Customer identifier |
| `CNTRY`           | Customer country    |

### Example

```text
CID,CNTRY
AW-00011000,Australia
```

### Observations

The ERP location dataset uses a different customer identifier format from the CRM source.

CRM:

```text
AW00011000
```

ERP:

```text
AW-00011000
```

The identifier-format difference needs to be addressed during data integration.

The original source value should be preserved in Bronze.

The standardized value can be created during Silver processing.

---

# 8. ERP Product Category

## 8.1 File

`PX_CAT_G1V2.csv`

### Business Purpose

Contains product category and subcategory information from the ERP source system.

### Columns

| ColumnDescription |                             |
| ----------------- | --------------------------- |
| `ID`              | Product category identifier |
| `CAT`             | Product category            |
| `SUBCAT`          | Product subcategory         |
| `MAINTENANCE`     | Maintenance requirement     |

### Example

```text
ID,CAT,SUBCAT,MAINTENANCE
AC_BR,Accessories,Bike Racks,Yes
```

### Observations

The dataset contains category-level information used to enrich the product information coming from the CRM system.

The product category identifier follows a structured format such as:

```text
AC_BR
BI_MB
CO_RF
```

CRM product keys contain structured prefixes such as:

```text
CO-RF-FR-R92B-58
```

The relationship between CRM product keys and ERP category identifiers requires validation during the integration stage.

The exact mapping logic should be documented after validation rather than assumed solely from the identifier format.

---

# 9. Source-to-Source Relationships

The source datasets contain relationships that support the construction of the warehouse model.

## 9.1 CRM Customer to CRM Sales

```text
cust_info.cst_id
       ↑
       |
sales_details.sls_cust_id
```

Relationship:

```text
sales_details.sls_cust_id → cust_info.cst_id
```

This relationship connects sales transactions to customers.

---

## 9.2 CRM Product to CRM Sales

```text
prd_info.prd_key
       ↑
       |
sales_details.sls_prd_key
```

Relationship:

```text
sales_details.sls_prd_key → prd_info.prd_key
```

This relationship connects sales transactions to products.

---

## 9.3 CRM Customer to ERP Demographics

CRM customer key:

```text
AW00011000
```

ERP demographic identifier:

```text
NASAW00011000
```

The identifier formats differ and require standardization before integration.

Conceptually:

```text
CRM Customer
AW00011000
      ↓
Standardization
      ↓
ERP Customer Demographics
NASAW00011000
```

The exact transformation rule must be validated as part of the integration process.

---

## 9.4 CRM Customer to ERP Location

CRM customer key:

```text
AW00011000
```

ERP location identifier:

```text
AW-00011000
```

The identifier formats differ.

Conceptually:

```text
CRM Customer
AW00011000
      ↓
Standardization
      ↓
ERP Location
AW-00011000
```

The transformation should be implemented in the Silver layer rather than modifying the original Bronze data.

---

## 9.5 CRM Product to ERP Category

CRM product keys contain structured components.

Example:

```text
CO-RF-FR-R92B-58
```

ERP category identifiers use a corresponding category-oriented format.

Example:

```text
CO_RF
```

This relationship requires validation before being used as an integration rule.

The product-category relationship should therefore be treated as an integration requirement to validate rather than assuming that the identifier pattern alone guarantees a match.

---

# 10. Source Data Flow

The source systems feed the warehouse through the Bronze, Silver, and Gold layers.

```text
                  SOURCE SYSTEMS
                       |
          +------------+------------+
          |                         |
         CRM                       ERP
          |                         |
   +------+------+          +-------+-------+
   |      |      |          |       |       |
Customer Product Sales   Customer  Location Category
   |      |      |       |       |       |
   +------+------+-------+-------+-------+
                       |
                       v
                  BRONZE LAYER
                       |
                       v
                  SILVER LAYER
                       |
                       v
                   GOLD LAYER
                       |
             +---------+---------+
             |         |         |
          Customers Products   Sales
```

---

# 11. Source-to-Bronze Mapping

The Bronze layer will preserve the source datasets with minimal transformation.

| Source SystemSource FileBronze Table |                     |                            |
| ------------------------------------ | ------------------- | -------------------------- |
| CRM                                  | `cust_info.csv`     | `bronze.crm_cust_info`     |
| CRM                                  | `prd_info.csv`      | `bronze.crm_prd_info`      |
| CRM                                  | `sales_details.csv` | `bronze.crm_sales_details` |
| ERP                                  | `CUST_AZ12.csv`     | `bronze.erp_cust_az12`     |
| ERP                                  | `LOC_A101.csv`      | `bronze.erp_loc_a101`      |
| ERP                                  | `PX_CAT_G1V2.csv`   | `bronze.erp_px_cat_g1v2`   |

The naming follows the source-system and entity naming approach:

```text
<sourcesystem>_<entity>
```

---

# 12. Source Data Quality Assessment

The source datasets contain several conditions that require validation and cleansing.

## 12.1 Customer Data

Observed considerations:

- Duplicate customer IDs
- Missing customer IDs
- Missing first names
- Missing last names
- Missing marital-status values
- Missing gender values
- Potentially incomplete customer records

These issues will be investigated in the Silver layer.

---

## 12.2 Product Data

Observed considerations:

- Missing product costs
- Repeated product keys
- Missing product end dates
- Product-line values requiring standardization
- Product date values requiring validation
- Potential multiple records associated with a product key

These conditions require business and data-quality rules before creating the Gold product dimension.

---

## 12.3 Sales Data

Observed considerations:

- Multiple records for the same sales order
- Multiple products associated with an order
- Transaction dates requiring validation
- Sales amount and price/quantity relationships requiring validation

A key validation rule is:

```text
sales_amount = quantity × price
```

This should be tested against the source data rather than assumed.

---

## 12.4 ERP Demographic Data

Observed considerations:

- Customer identifiers use a different format from CRM.
- Some gender values are missing.
- Birth dates require validation.

---

## 12.5 ERP Location Data

Observed considerations:

- Customer identifiers use a different format from CRM.
- Country values should be standardized during Silver processing where required.

---

## 12.6 ERP Product Category Data

Observed considerations:

- Product category identifiers need to be matched with CRM product keys.
- Category and subcategory values should be validated.
- Maintenance values should be standardized into a consistent representation.

---

# 13. Identifier Standardization Requirements

Identifier inconsistencies are particularly important because data from multiple source systems must eventually be integrated.

## Customer Identifier

CRM:

```text
AW00011000
```

ERP demographics:

```text
NASAW00011000
```

ERP location:

```text
AW-00011000
```

The warehouse should preserve the original identifiers in Bronze while creating standardized values during Silver processing.

Conceptually:

```text
                    CRM
                AW00011000
                    |
                    |
             Standardization
              /             \
             /               \
            v                 v
 NASAW00011000           AW-00011000
 ERP Demographics        ERP Location
```

---

# 14. Bronze Layer Implications

The source analysis supports the following Bronze-layer principles:

1. Preserve source data as received.
2. Avoid business transformations.
3. Preserve source identifiers.
4. Preserve source-level data-quality issues.
5. Maintain traceability back to the source.
6. Load the complete source datasets.
7. Use the Bronze layer as the foundation for downstream cleansing and integration.

Therefore, Bronze should not remove duplicates, normalize identifiers, or correct missing values.

---

# 15. Silver Layer Implications

The source analysis identifies several transformations that belong in the Silver layer.

Expected Silver activities include:

- Data cleansing
- Standardization
- Handling missing values
- Identifier standardization
- Date validation
- Data-type normalization
- Product and customer integration
- Validation of relationships
- Derivation of required fields
- Applying documented business rules

The Silver layer should produce consistent and reliable datasets that can be integrated into the Gold layer.

---

# 16. Gold Layer Implications

The source analysis supports the following conceptual Gold model:

```text
                 +----------------------+
                 |   dim_customers      |
                 |----------------------|
                 | customer_key         |
                 | customer_id          |
                 | customer_number      |
                 | first_name           |
                 | last_name            |
                 | country              |
                 | marital_status       |
                 | gender               |
                 | birthdate            |
                 | create_date          |
                 +----------+-----------+
                            |
                            |
                            v
                 +----------------------+
                 |      fact_sales      |
                 |----------------------|
                 | order_number         |
                 | product_key          |
                 | customer_key         |
                 | order_date           |
                 | shipping_date        |
                 | due_date             |
                 | sales_amount         |
                 | quantity             |
                 | price                |
                 +----------+-----------+
                            ^
                            |
                            |
                 +----------+-----------+
                 |   dim_products       |
                 |----------------------|
                 | product_key          |
                 | product_id           |
                 | product_number       |
                 | product_name         |
                 | category_id          |
                 | category             |
                 | subcategory          |
                 | maintenance_required |
                 | cost                 |
                 | product_line         |
                 | start_date           |
                 +----------------------+
```

The Gold layer combines information from the source systems into business-ready analytical structures.

---

# 17. Proposed Gold Data Integration

## 17.1 Customer Dimension

The customer dimension is expected to combine information from:

```text
CRM Customer
    |
    +-- cust_info.csv
    |
    +-- ERP CUST_AZ12.csv
    |
    +-- ERP LOC_A101.csv
    |
    v
dim_customers
```

The resulting customer dimension is intended to contain customer information enriched with demographic and geographic information.

---

## 17.2 Product Dimension

The product dimension is expected to combine:

```text
CRM Product
    |
    +-- prd_info.csv
    |
    +-- ERP PX_CAT_G1V2.csv
    |
    v
dim_products
```

This provides product information together with category and subcategory information.

---

## 17.3 Sales Fact

The sales fact is primarily derived from:

```text
sales_details.csv
        |
        v
fact_sales
```

The fact table will connect sales transactions to the customer and product dimensions.

Conceptually:

```text
dim_customers
      |
      |
      v
  fact_sales
      ^
      |
      |
dim_products
```

---

# 18. Key Source-System Findings

The source analysis establishes the following important findings:

### Finding 1 — Two source systems are involved

```text
CRM + ERP
```

Both systems provide information required by the analytical model.

### Finding 2 — Customer information is distributed

Customer information is available across:

```text
cust_info.csv
CUST_AZ12.csv
LOC_A101.csv
```

These datasets need to be integrated.

### Finding 3 — Product information is distributed

Product information is available across:

```text
prd_info.csv
PX_CAT_G1V2.csv
```

These datasets need to be integrated.

### Finding 4 — Sales transactions originate from CRM

```text
sales_details.csv
```

provides the transactional sales data used to build the sales fact.

### Finding 5 — Customer identifiers are inconsistent

The same customer integration requires handling different identifier formats across systems.

### Finding 6 — Product identifiers require validation

The product key and ERP category identifier relationship should be validated before defining the final integration rule.

### Finding 7 — Source data contains quality issues

Missing values, duplicates, repeated product keys, and date/value inconsistencies require downstream validation and cleansing.

---

# 19. Source Analysis to Implementation Mapping

| Source FindingLayerExpected Action |        |                                       |
| ---------------------------------- | ------ | ------------------------------------- |
| Raw CSV data                       | Bronze | Preserve source data                  |
| Duplicate customer records         | Silver | Investigate and apply documented rule |
| Missing customer attributes        | Silver | Apply documented data-quality rule    |
| Different customer ID formats      | Silver | Standardize identifiers               |
| Missing product costs              | Silver | Validate and handle according to rule |
| Repeated product keys              | Silver | Investigate product-version behavior  |
| Product category mapping           | Silver | Validate integration                  |
| Sales date values                  | Silver | Validate and standardize              |
| Sales amount relationship          | Silver | Validate `quantity × price`           |
| Integrated customer data           | Gold   | Build `dim_customers`                 |
| Integrated product data            | Gold   | Build `dim_products`                  |
| Sales transactions                 | Gold   | Build `fact_sales`                    |

---

# 20. Questions for Further Validation

The source files provide the initial technical understanding, but some business rules require validation before implementation.

### Customer

- What is the authoritative customer identifier?
- How should duplicate customer records be handled?
- Which customer attributes should take precedence when CRM and ERP values differ?
- How should missing demographic information be handled?

### Product

- Why do multiple records contain the same `prd_key`?
- Does each record represent a product version or another business concept?
- How should the active product record be identified?
- How should missing product costs be handled?
- What is the exact mapping between CRM product keys and ERP category IDs?

### Sales

- What is the exact grain of a sales record?
- Should each row represent one sales order line?
- How should invalid dates be handled?
- Should sales amounts always equal quantity multiplied by price?

These questions should be resolved through data exploration, validation, and documented business rules before finalizing the Gold model.

---

# 21. Source Analysis Conclusion

The source environment consists of two systems, CRM and ERP, represented by six CSV datasets.

The CRM system provides:

```text
Customer Information
Product Information
Sales Transactions
```

The ERP system provides:

```text
Customer Demographics
Customer Location
Product Categories
```

The datasets contain relationships that allow customer, product, and sales information to be integrated into an analytical data warehouse.

However, the source data also contains data-quality and integration challenges, including:

- Duplicate records
- Missing values
- Different identifier formats
- Repeated product keys
- Date-quality considerations
- Product-category mapping requirements

These issues reinforce the need for a layered architecture:

```text
SOURCE SYSTEMS
      |
      v
+-------------+
|   BRONZE    |
| Raw Source  |
+-------------+
      |
      v
+-------------+
|   SILVER    |
| Cleaned &   |
| Integrated  |
+-------------+
      |
      v
+-------------+
|    GOLD     |
| Business-   |
| Ready Data  |
+-------------+
```

The source analysis therefore provides the foundation for the next implementation stages:

1. Design the MySQL Bronze layer.
2. Create Bronze tables.
3. Load the source datasets without transformation.
4. Validate Bronze completeness and schema.
5. Design and implement Silver transformations.
6. Validate cleansing and integration.
7. Build the Gold analytical model.
8. Validate the final customer, product, and sales relationships.
9. Build analytics and reporting on top of the Gold layer.

---

## 22. Source Files

### CRM

```text
cust_info.csv
prd_info.csv
sales_details.csv
```

### ERP

```text
CUST_AZ12.csv
LOC_A101.csv
PX_CAT_G1V2.csv
```

---

## 23. Target Warehouse Objects

### Bronze

```text
bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2
```

### Silver

```text
silver.crm_cust_info
silver.crm_prd_info
silver.crm_sales_details
silver.erp_cust_az12
silver.erp_loc_a101
silver.erp_px_cat_g1v2
```

### Gold

```text
gold.dim_customers
gold.dim_products
gold.fact_sales
```

---

## 24. Next Step

The next stage is the **Bronze Layer**.

The Bronze implementation will focus on:

```text
Source CSV
    ↓
Bronze Table
    ↓
Full Load
    ↓
Validation
    ↓
Documentation
    ↓
Git Commit
```

No cleansing or business transformation should be performed during Bronze loading.

```
```
