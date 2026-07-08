-- ============================================================
-- Problem   : User's Third Transaction
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : <e.g. CTEs, Window Functions, Self Join>
-- URL       : https://datalemur.com/questions/sql-third-transaction
-- Solved    : 2026-07-08
-- ============================================================

-- PROBLEM STATEMENT:
-- Assume you are given the table below on Uber transactions made by users. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

-- SOLUTION:

WITH rnk_transaction AS 
(
  SELECT user_id, spend, transaction_date,
    row_number() OVER(
                      PARTITION by user_id 
                      ORDER BY transaction_date ASC) AS rnk
  FROM transactions
)
SELECT user_id, spend, transaction_date
FROM rnk_transaction
WHERE rnk = 3

-- WHAT I LEARNED / NOTES:
-- Gotchas: Third transaction is asked but not mentioned if its the initial one or the recent most.
-- look for transaction_date ASC which gives initial 3rd transaction
