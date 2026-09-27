/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity,
    consistency, and accuracy of the Gold layer.

    These checks validate:
        - Uniqueness of surrogate keys in dimension views.
        - Referential integrity between fact and dimension views.
        - Connectivity of the Star Schema.
        - Relationships between fact and dimension objects.

Gold objects checked:
        - gold.dim_customers
        - gold.dim_products
        - gold.fact_sales

Expectation:
    All queries should return an empty result set.

Usage:
    Run this script after creating and loading the Gold layer views.
    Any returned rows should be investigated before considering
    the Gold layer complete.

MySQL Implementation Note:
    The reference project uses SQL Server. This implementation
    uses MySQL-compatible syntax and separate databases for the
    Bronze, Silver, and Gold layers.
===============================================================================
*/


-- ====================================================================
-- Checking gold.dim_customers
-- ====================================================================

-- Check for uniqueness of customer_key
-- Expectation: No results

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking gold.dim_products
-- ====================================================================

-- Check for uniqueness of product_key
-- Expectation: No results

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ====================================================================
-- Checking gold.fact_sales
-- ====================================================================

-- Check connectivity between fact and dimension views.
-- Expectation: No results.
--
-- Every fact record should have a matching customer
-- and product dimension record.

SELECT
    f.order_number,
    f.product_key,
    f.customer_key
FROM gold.fact_sales f

LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key

LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key

WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;
