/*
=============================================================
Create Data Warehouse Databases
=============================================================
Script Purpose:
    This script creates the three databases used to implement
    the Data Warehouse layers:

        - bronze
        - silver
        - gold

    In MySQL, a database is also referred to as a schema.
    For this project, each layer is implemented as a separate
    database.

WARNING:
    The DROP DATABASE statements permanently delete the
    corresponding databases and all data inside them.

    Run this script only when intentionally recreating the
    Data Warehouse environment from scratch.
=============================================================
*/

-- ===========================================================
-- Drop and recreate the 'bronze' database
-- ===========================================================

DROP DATABASE IF EXISTS bronze;

CREATE DATABASE bronze;


-- ===========================================================
-- Drop and recreate the 'silver' database
-- ===========================================================

DROP DATABASE IF EXISTS silver;

CREATE DATABASE silver;


-- ===========================================================
-- Drop and recreate the 'gold' database
-- ===========================================================

DROP DATABASE IF EXISTS gold;

CREATE DATABASE gold;
