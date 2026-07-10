-- ============================================================
-- Problem   : Best-Selling Product
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Window Functions
-- URL       : https://datalemur.com/questions/best-selling-products
-- Solved    : 2026-07-10
-- ============================================================

-- PROBLEM STATEMENT:
-- Write an SQL query to find the best-selling product in each product category. If there are two or more products with the same sales quantity, go by whichever product which has the higher review rating.
-- Return the category name and product name in alphabetical order of the category.

-- APPROACH:
-- Create ranked products table first
-- make final selection based on rank

-- SOLUTION:

WITH ranked_products AS(
  SELECT category_name, product_name,
        row_number() OVER(PARTITION BY category_name ORDER BY sales_quantity DESC, rating DESC) as rn
  FROM product_sales ps
  LEFT JOIN products p on ps.product_id = p.product_id
  )
  select category_name, product_name
  FROM ranked_products
  WHERE rn = 1;
  
-- WHAT I LEARNED / NOTES: