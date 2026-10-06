-- =========================================================================
-- Part 1, Task 3: Reports (`sql/reports.sql`)
-- =========================================================================

-- a) Order totals
-- Expected: total_orders = 180, total_revenue = 99860.20, avg_order_value = 554.78
SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;


-- b) COUNT(*) vs COUNT(column)
-- Expected: (180, 165, 15) — 15 orders have no rating yet.
SELECT 
    COUNT(*) AS count_star,
    COUNT(rating) AS count_rating,
    COUNT(*) - COUNT(rating) AS diff
FROM orders;


-- c) LEFT JOIN with a genuine zero-match row
-- Expected: both queries return exactly one row — C045, Vihaan.
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) = 0;

-- Confirmation query using NOT IN
SELECT customer_id, name
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);


-- d) GROUP BY + HAVING
-- Expected exactly 3 rows: Jaipur (19, 8, 42.1), Lucknow (49, 15, 30.6), Bangalore (33, 8, 24.2).
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.returned) AS returned_orders,
    ROUND(SUM(o.returned) * 100.0 / COUNT(o.order_id), 1) AS return_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
HAVING return_rate_pct > 20
ORDER BY return_rate_pct DESC;


-- e) Ranking with ORDER BY + LIMIT/OFFSET
-- Note: The tie-break on customer_id ASC is essential to guarantee deterministic, stable ordering when top spend values match.
-- Expected top 5: C043 Reyansh 12920.00, C026 Isha 8371.60, C008 Meera 4564.60, C011 Arjun 4111.00, C042 Sanya 3785.00.
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- LIMIT 3 OFFSET 2 query to get ranks 3-5
-- Expected: C008 Meera 4564.60, C011 Arjun 4111.00, C042 Sanya 3785.00
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;


-- f) Three-table JOIN with GROUP BY
-- Expected: Haircare (54, 44956.10), Skincare (60, 27346.00), Babycare (30, 16805.00), PersonalCare (36, 10753.10).
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- g) LIKE pattern match
-- Expected: exactly 10 rows.
SELECT *
FROM customers
WHERE name LIKE 'A%';


-- h) DISTINCT
-- Expected: exactly 4 values — Ad, Organic, Referral, Social.
SELECT DISTINCT acquisition_source
FROM customers;


-- i) ALTER TABLE + UPDATE with CASE
-- Expected: Gold, 28 and Silver, 17.
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

UPDATE customers 
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

SELECT loyalty_tier, COUNT(*) AS count 
FROM customers 
GROUP BY loyalty_tier;
