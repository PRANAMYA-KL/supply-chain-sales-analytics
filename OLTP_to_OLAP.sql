/* ============================================================
   SUPPLY CHAIN SALES ANALYTICS
   OLTP TO OLAP DATA WAREHOUSE TRANSFORMATION
   ============================================================

   Source OLTP Tables:
   department
   category
   product_info
   customer_info
   orders
   ordered_items

   Target OLAP Tables:
   Dim_Date
   Dim_Customer
   Dim_Product
   Dim_Geography
   Dim_Shipping
   Fact_Order_Sales

   Fact Table Grain:
   One row = one order line item
   ============================================================ */


CREATE DATABASE IF NOT EXISTS supply_db2;

USE supply_db2;


/* ============================================================
   1. DATE DIMENSION
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter VARCHAR(10),
    month INT,
    month_name VARCHAR(20)
);


/* ============================================================
   2. CUSTOMER DIMENSION
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dim_Customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(255),
    segment VARCHAR(100)
);


/* ============================================================
   3. PRODUCT DIMENSION
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dim_Product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(255),
    category_name VARCHAR(255),
    department_name VARCHAR(255)
);


/* ============================================================
   4. GEOGRAPHY DIMENSION
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dim_Geography (
    geography_key INT AUTO_INCREMENT PRIMARY KEY,
    order_state VARCHAR(100),
    order_city VARCHAR(100)
);


/* ============================================================
   5. SHIPPING DIMENSION
   ============================================================ */

CREATE TABLE IF NOT EXISTS Dim_Shipping (
    shipping_key INT AUTO_INCREMENT PRIMARY KEY,
    shipping_mode VARCHAR(100),
    order_type VARCHAR(100),
    order_status VARCHAR(100)
);


/* ============================================================
   6. FACT ORDER SALES
   Grain: One row per order line item
   ============================================================ */

CREATE TABLE IF NOT EXISTS Fact_Order_Sales (
    fact_key INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    customer_id INT,
    date_key INT,
    geography_key INT,
    shipping_key INT,

    quantity_sold INT,
    sales_amount DECIMAL(15,2),

    real_shipping_days DECIMAL(10,2),
    scheduled_shipping_days DECIMAL(10,2),
    shipping_delay_days DECIMAL(10,2)
);


/* ============================================================
   DATA VALIDATION
   ============================================================ */

SELECT COUNT(*) AS fact_order_sales_count
FROM Fact_Order_Sales;


/* Expected fact-table grain validation:
   approximately 4,783 order-line records
*/