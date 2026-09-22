/*
===============================================================================
Bronze Layer: Load Source Data
===============================================================================
Script Purpose:
    This script loads raw source data from CSV files into the Bronze layer.

    The Bronze layer stores source data as received, without applying
    data cleansing, standardization, integration, or business transformations.

Load Strategy:
    - Full Load
    - Existing Bronze data is removed using TRUNCATE TABLE
    - CSV files are loaded using LOAD DATA LOCAL INFILE
    - Source headers are skipped
    - Windows CSV line endings are handled using '\r\n'
    - Load duration is measured for each table
    - Overall batch start/end time and duration are recorded

MySQL Adaptation:
    - MySQL databases are used as Bronze/Silver/Gold layers.
    - LOAD DATA LOCAL INFILE is used for CSV ingestion.
    - LOAD DATA LOCAL INFILE cannot be executed inside a stored procedure
      in MySQL, so this script is intentionally implemented as a standalone
      loading script.
    - The MySQL client must permit LOCAL INFILE loading.

Source Systems:
    - CRM
    - ERP

Source Files:
    CRM:
        cust_info.csv
        prd_info.csv
        sales_details.csv

    ERP:
        CUST_AZ12.csv
        LOC_A101.csv
        PX_CAT_G1V2.csv

WARNING:
    This is a FULL LOAD.

    Running this script will permanently remove the existing data from
    the six Bronze tables before reloading them.
IMPORTANT:
    This script uses LOAD DATA LOCAL INFILE.

    The MySQL server must have:
        local_infile = ON

    The MySQL client must also enable LOCAL INFILE.

    Recommended execution:

    mysql --local-infile=1 -u root -p < scripts/bronze/load_bronze.sql

    MySQL Workbench may reject LOCAL INFILE requests depending on its
    client-side security configuration. The MySQL command-line client
    with --local-infile=1 is therefore the recommended execution method.

===============================================================================
*/


/*
===============================================================================
1. INITIALIZE LOAD
===============================================================================
*/

SET @batch_start_time = NOW();

SELECT
    'Bronze Layer Load Started' AS message,
    @batch_start_time AS batch_start_time;


/*
===============================================================================
2. CRM CUSTOMER INFORMATION
===============================================================================
*/

SELECT 'Loading bronze.crm_cust_info...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'crm_cust_info' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
3. CRM PRODUCT INFORMATION
===============================================================================
*/

SELECT 'Loading bronze.crm_prd_info...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_prd_info;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'crm_prd_info' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
4. CRM SALES DETAILS
===============================================================================
*/

SELECT 'Loading bronze.crm_sales_details...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.crm_sales_details;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'crm_sales_details' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
5. ERP CUSTOMER DEMOGRAPHICS
===============================================================================
*/

SELECT 'Loading bronze.erp_cust_az12...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_cust_az12;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'erp_cust_az12' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
6. ERP CUSTOMER LOCATION
===============================================================================
*/

SELECT 'Loading bronze.erp_loc_a101...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_loc_a101;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'erp_loc_a101' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
7. ERP PRODUCT CATEGORY
===============================================================================
*/

SELECT 'Loading bronze.erp_px_cat_g1v2...' AS message;

SET @start_time = NOW();

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

LOAD DATA LOCAL INFILE
'C:/MySQL_Data_Warehouse/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET @end_time = NOW();

SELECT
    'erp_px_cat_g1v2' AS table_name,
    @start_time AS start_time,
    @end_time AS end_time,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000000
        AS duration_seconds,
    ROW_COUNT() AS rows_affected;


/*
===============================================================================
8. COMPLETE BATCH
===============================================================================
*/

SET @batch_end_time = NOW();

SELECT
    'Bronze Layer Load Completed' AS message,
    @batch_start_time AS batch_start_time,
    @batch_end_time AS batch_end_time,
    TIMESTAMPDIFF(MICROSECOND, @batch_start_time, @batch_end_time) / 1000000
        AS total_duration_seconds;


/*
===============================================================================
9. BASIC ROW COUNT VALIDATION
===============================================================================
*/

SELECT
    'bronze.crm_cust_info' AS table_name,
    COUNT(*) AS row_count
FROM bronze.crm_cust_info

UNION ALL

SELECT
    'bronze.crm_prd_info',
    COUNT(*)
FROM bronze.crm_prd_info

UNION ALL

SELECT
    'bronze.crm_sales_details',
    COUNT(*)
FROM bronze.crm_sales_details

UNION ALL

SELECT
    'bronze.erp_cust_az12',
    COUNT(*)
FROM bronze.erp_cust_az12

UNION ALL

SELECT
    'bronze.erp_loc_a101',
    COUNT(*)
FROM bronze.erp_loc_a101

UNION ALL

SELECT
    'bronze.erp_px_cat_g1v2',
    COUNT(*)
FROM bronze.erp_px_cat_g1v2;
