/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity,
    consistency, and accuracy of the Gold layer.

    These checks validate:
        - Uniqueness of surrogate keys in dimension views.
        - Validity of customer business identifiers.
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
    Run this script after creating the Gold layer views.
    Any returned rows should be investigated before considering
    the Gold layer complete.

MySQL Implementation Note:
    The reference project uses SQL Server. This implementation
    uses MySQL-compatible syntax and separate databases for the
    Bronze, Silver, and Gold layers.
===============================================================================
*/


-- ============================================================================
-- 1. Customer Surrogate Key Uniqueness
-- ============================================================================

SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- 2. Product Surrogate Key Uniqueness
-- ============================================================================

SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- ============================================================================
-- 3. Invalid Customer IDs
-- ============================================================================

SELECT *
FROM gold.dim_customers
WHERE customer_id <= 0;


-- ============================================================================
-- 4. Customer Business ID Uniqueness
-- ============================================================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- ============================================================================
-- 5. Fact-to-Dimension Connectivity
-- ============================================================================

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
