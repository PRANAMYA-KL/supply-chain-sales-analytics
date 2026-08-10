/* ============================================================
   SUPPLY CHAIN SALES ANALYTICS
   BUSINESS ANALYSIS QUERIES
   ============================================================ */

USE supply_db2;


/* ============================================================
   1. TOTAL ORDERS
   ============================================================ */

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM Fact_Order_Sales;


/* ============================================================
   2. TOTAL REVENUE
   ============================================================ */

SELECT
    ROUND(SUM(sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales;


/* ============================================================
   3. TOTAL UNITS SOLD
   ============================================================ */

SELECT
    SUM(quantity_sold) AS total_units_sold
FROM Fact_Order_Sales;


/* ============================================================
   4. AVERAGE SHIPPING DELAY
   ============================================================ */

SELECT
    ROUND(AVG(shipping_delay_days), 2) AS average_shipping_delay
FROM Fact_Order_Sales;


/* ============================================================
   5. REVENUE BY DEPARTMENT
   ============================================================ */

SELECT
    p.department_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Product p
    ON f.product_id = p.product_id
GROUP BY p.department_name
ORDER BY total_revenue DESC;


/* ============================================================
   6. TOP 5 DEPARTMENTS BY REVENUE
   ============================================================ */

SELECT
    p.department_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Product p
    ON f.product_id = p.product_id
GROUP BY p.department_name
ORDER BY total_revenue DESC
LIMIT 5;


/* ============================================================
   7. TOP 5 STATES BY REVENUE
   ============================================================ */

SELECT
    g.order_state,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Geography g
    ON f.geography_key = g.geography_key
GROUP BY g.order_state
ORDER BY total_revenue DESC
LIMIT 5;


/* ============================================================
   8. REVENUE BY CUSTOMER SEGMENT
   ============================================================ */

SELECT
    c.segment,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Customer c
    ON f.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_revenue DESC;


/* ============================================================
   9. TOP 5 PRODUCTS BY REVENUE
   ============================================================ */

SELECT
    p.product_name,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Product p
    ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;


/* ============================================================
   10. REVENUE BY SHIPPING MODE
   ============================================================ */

SELECT
    s.shipping_mode,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Shipping s
    ON f.shipping_key = s.shipping_key
GROUP BY s.shipping_mode
ORDER BY total_revenue DESC;


/* ============================================================
   11. AVERAGE SHIPPING DELAY BY SHIPPING MODE
   ============================================================ */

SELECT
    s.shipping_mode,
    ROUND(AVG(f.shipping_delay_days), 2) AS average_shipping_delay
FROM Fact_Order_Sales f
JOIN Dim_Shipping s
    ON f.shipping_key = s.shipping_key
GROUP BY s.shipping_mode
ORDER BY average_shipping_delay DESC;


/* ============================================================
   12. REVENUE BY YEAR
   ============================================================ */

SELECT
    d.year,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Date d
    ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;


/* ============================================================
   13. REVENUE BY QUARTER
   ============================================================ */

SELECT
    d.quarter,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Date d
    ON f.date_key = d.date_key
GROUP BY d.quarter
ORDER BY d.quarter;


/* ============================================================
   14. REVENUE BY YEAR AND QUARTER
   ============================================================ */

SELECT
    d.year,
    d.quarter,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.quarter
ORDER BY
    d.year,
    d.quarter;


/* ============================================================
   15. REVENUE BY DEPARTMENT AND QUARTER
   ============================================================ */

SELECT
    p.department_name,
    d.quarter,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Product p
    ON f.product_id = p.product_id
JOIN Dim_Date d
    ON f.date_key = d.date_key
GROUP BY
    p.department_name,
    d.quarter
ORDER BY
    p.department_name,
    total_revenue DESC;


/* ============================================================
   16. REVENUE VS UNITS SOLD BY PRODUCT
   ============================================================ */

SELECT
    p.product_name,
    SUM(f.quantity_sold) AS total_units_sold,
    ROUND(SUM(f.sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales f
JOIN Dim_Product p
    ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;


/* ============================================================
   17. SHIPPING PERFORMANCE
   ============================================================ */

SELECT
    s.shipping_mode,
    ROUND(AVG(f.real_shipping_days), 2) AS avg_real_shipping_days,
    ROUND(AVG(f.scheduled_shipping_days), 2)
        AS avg_scheduled_shipping_days,
    ROUND(AVG(f.shipping_delay_days), 2)
        AS avg_shipping_delay_days
FROM Fact_Order_Sales f
JOIN Dim_Shipping s
    ON f.shipping_key = s.shipping_key
GROUP BY s.shipping_mode
ORDER BY avg_shipping_delay_days DESC;


/* ============================================================
   18. TOP DEPARTMENT FOR EACH QUARTER
   ============================================================ */

WITH department_revenue AS (
    SELECT
        d.quarter,
        p.department_name,
        SUM(f.sales_amount) AS total_revenue
    FROM Fact_Order_Sales f
    JOIN Dim_Product p
        ON f.product_id = p.product_id
    JOIN Dim_Date d
        ON f.date_key = d.date_key
    GROUP BY
        d.quarter,
        p.department_name
),
ranked_departments AS (
    SELECT
        quarter,
        department_name,
        total_revenue,
        RANK() OVER (
            PARTITION BY quarter
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM department_revenue
)
SELECT
    quarter,
    department_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM ranked_departments
WHERE revenue_rank = 1
ORDER BY quarter;


/* ============================================================
   19. TOP 5 PRODUCTS USING RANK
   ============================================================ */

WITH product_revenue AS (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue
    FROM Fact_Order_Sales f
    JOIN Dim_Product p
        ON f.product_id = p.product_id
    GROUP BY p.product_name
),
ranked_products AS (
    SELECT
        product_name,
        total_revenue,
        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    revenue_rank,
    product_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM ranked_products
WHERE revenue_rank <= 5
ORDER BY revenue_rank;


/* ============================================================
   20. DATA QUALITY CHECK
   ============================================================ */

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(quantity_sold) AS total_units_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue
FROM Fact_Order_Sales;