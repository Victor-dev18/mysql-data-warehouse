/*
=============================================================
Silver Layer - Data Loading
=============================================================
Script Purpose:
    This script loads cleaned and standardized data from
    the Bronze layer into the Silver layer.

    The Silver layer applies:
        - Data cleansing
        - Standardization
        - Normalization
        - Derived columns
        - Data integration
        - Business rules
        - Basic data quality handling

Load Strategy:
    Full Load
        1. TRUNCATE existing Silver tables
        2. INSERT transformed data from Bronze

MySQL Implementation Note:
    This project uses standalone SQL statements rather than
    a stored procedure.

    This is a MySQL-specific implementation decision due to
    limitations encountered with LOAD DATA and SQL editor
    delimiter handling during the project.

Source:
    Bronze database

Target:
    Silver database
=============================================================
*/


-- ===========================================================
-- 1. CRM CUSTOMER INFORMATION
-- ===========================================================

TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'M'
            THEN 'Married'
        WHEN UPPER(TRIM(cst_marital_status)) = 'S'
            THEN 'Single'
        ELSE 'n/a'
    END AS cst_marital_status,

    CASE
        WHEN UPPER(TRIM(cst_gndr)) IN ('M', 'MALE')
            THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) IN ('F', 'FEMALE')
            THEN 'Female'
        ELSE 'n/a'
    END AS cst_gndr,

    CASE
        WHEN cst_create_date IS NULL
             OR TRIM(cst_create_date) = ''
             OR TRIM(cst_create_date) = '0000-00-00'
            THEN NULL
        ELSE STR_TO_DATE(TRIM(cst_create_date), '%Y-%m-%d')
    END AS cst_create_date

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY
                CASE
                    WHEN cst_create_date IS NULL
                         OR TRIM(cst_create_date) = ''
                         OR TRIM(cst_create_date) = '0000-00-00'
                        THEN '1900-01-01'
                    ELSE cst_create_date
                END DESC
        ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) AS deduplicated
WHERE rn = 1;


-- ===========================================================
-- 2. CRM PRODUCT INFORMATION
-- ===========================================================

TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,

    REPLACE(
        SUBSTRING_INDEX(prd_key, '-', 2),
        '-',
        '_'
    ) AS cat_id,

    TRIM(prd_key) AS prd_key,

    TRIM(prd_nm) AS prd_nm,

    COALESCE(prd_cost, 0) AS prd_cost,

    CASE
        WHEN UPPER(TRIM(prd_line)) = 'M'
            THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R'
            THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S'
            THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T'
            THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,

    prd_start_dt,

    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) AS prd_end_dt

FROM bronze.crm_prd_info;


-- ===========================================================
-- 3. CRM SALES DETAILS
-- ===========================================================

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN sls_order_dt IS NULL
             OR sls_order_dt <= 0
             OR LENGTH(CAST(sls_order_dt AS CHAR)) != 8
            THEN NULL
        ELSE STR_TO_DATE(
            CAST(sls_order_dt AS CHAR),
            '%Y%m%d'
        )
    END AS sls_order_dt,

    CASE
        WHEN sls_ship_dt IS NULL
             OR sls_ship_dt <= 0
             OR LENGTH(CAST(sls_ship_dt AS CHAR)) != 8
            THEN NULL
        ELSE STR_TO_DATE(
            CAST(sls_ship_dt AS CHAR),
            '%Y%m%d'
        )
    END AS sls_ship_dt,

    CASE
        WHEN sls_due_dt IS NULL
             OR sls_due_dt <= 0
             OR LENGTH(CAST(sls_due_dt AS CHAR)) != 8
            THEN NULL
        ELSE STR_TO_DATE(
            CAST(sls_due_dt AS CHAR),
            '%Y%m%d'
        )
    END AS sls_due_dt,

    /*
    Correct invalid or inconsistent sales values using
    quantity × cleaned price.
    */
    CASE
        WHEN sls_sales IS NULL
             OR sls_sales <= 0
            THEN sls_quantity * cleaned_price

        WHEN sls_sales != sls_quantity * cleaned_price
            THEN sls_quantity * cleaned_price

        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    cleaned_price AS sls_price

FROM (
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,

        /*
        Some source rows contain price = 0 while sales
        and quantity contain usable values.

        Derive price from sales / quantity in those cases.
        */
        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)

            ELSE sls_price
        END AS cleaned_price

    FROM bronze.crm_sales_details
) AS cleaned_sales;


-- ===========================================================
-- 4. ERP CUSTOMER DEMOGRAPHICS
-- ===========================================================

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE
        WHEN LEFT(TRIM(cid), 3) = 'NAS'
            THEN SUBSTRING(TRIM(cid), 4)
        ELSE TRIM(cid)
    END AS cid,

    CASE
        WHEN bdate > CURRENT_DATE()
            THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
            THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
            THEN 'Female'
        ELSE 'n/a'
    END AS gen

FROM bronze.erp_cust_az12;


-- ===========================================================
-- 5. ERP CUSTOMER LOCATION
-- ===========================================================

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(TRIM(cid), '-', '') AS cid,

    CASE
        WHEN TRIM(cntry) = ''
             OR cntry IS NULL
            THEN 'n/a'

        WHEN UPPER(TRIM(cntry)) = 'DE'
            THEN 'Germany'

        WHEN UPPER(TRIM(cntry)) = 'US'
            THEN 'United States'

        WHEN UPPER(TRIM(cntry)) = 'USA'
            THEN 'United States'

        ELSE TRIM(cntry)
    END AS cntry

FROM bronze.erp_loc_a101;


-- ===========================================================
-- 6. ERP PRODUCT CATEGORY
-- ===========================================================

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    TRIM(id),
    TRIM(cat),
    TRIM(subcat),
    TRIM(maintenance)

FROM bronze.erp_px_cat_g1v2;


-- ===========================================================
-- 7. FINAL ROW COUNT VALIDATION
-- ===========================================================

SELECT
    'crm_cust_info' AS table_name,
    COUNT(*) AS row_count
FROM silver.crm_cust_info

UNION ALL

SELECT
    'crm_prd_info',
    COUNT(*)
FROM silver.crm_prd_info

UNION ALL

SELECT
    'crm_sales_details',
    COUNT(*)
FROM silver.crm_sales_details

UNION ALL

SELECT
    'erp_cust_az12',
    COUNT(*)
FROM silver.erp_cust_az12

UNION ALL

SELECT
    'erp_loc_a101',
    COUNT(*)
FROM silver.erp_loc_a101

UNION ALL

SELECT
    'erp_px_cat_g1v2',
    COUNT(*)
FROM silver.erp_px_cat_g1v2;
