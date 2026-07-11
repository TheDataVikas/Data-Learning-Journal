-- ============================================================
-- Problem   : Supercloud Customer
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Subquery
-- URL       : https://datalemur.com/questions/supercloud-customer
-- Solved    : 2026-07-11
-- ============================================================

-- PROBLEM STATEMENT:
-- A Microsoft Azure Supercloud customer is defined as a customer who has purchased at least one product from every product category listed in the products table.

-- Write a query that identifies the customer IDs of these Supercloud customers.

-- APPROACH:
-- join the table and group the customer_id
-- look for product_category count for each customer and match it with distinct count of product_category 

-- SOLUTION:

SELECT customer_id
FROM customer_contracts cc
LEFT JOIN products p ON cc.product_id = p.product_id
GROUP BY customer_id 
HAVING count(DISTINCT product_category)
        = (SELECT count(DISTINCT product_category) FROM products)

-- WHAT I LEARNED / NOTES:
-- Gotcha: Remember the distinct
