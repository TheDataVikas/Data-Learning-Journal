-- ============================================================
-- Problem   : Card Launch Success
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Window Functions
-- URL       : https://datalemur.com/questions/card-launch-success
-- Solved    : 2026-07-10
-- ============================================================

-- PROBLEM STATEMENT:
-- Your team at JPMorgan Chase is soon launching a new credit card. You are asked to estimate how many cards you'll issue in the first month.

-- Before you can answer this question, you want to first get some perspective on how well new credit card launches typically do in their first month.

-- Write a query that outputs the name of the credit card, and how many cards were issued in its launch month. The launch month is the earliest record in the monthly_cards_issued table for a given card. Order the results starting from the biggest issued amount.

-- APPROACH:
-- Create a ranked monthly card issued cte first
-- make final selection based on rank

-- SOLUTION:

WITH ranked_monthly_cards_issued as(
SELECT card_name, issued_amount,
        row_number() OVER(PARTITION BY card_name ORDER BY issue_year ASC, issue_month ASC, issued_amount DESC) as rn
FROM monthly_cards_issued
)
SELECT card_name, issued_amount
FROM ranked_monthly_cards_issued
WHERE rn = 1
order by issued_amount DESC;

-- ALTERNATIVE APPROACH (if any):

-- WHAT I LEARNED / NOTES:
-- Do not miss last ORDER BY. ;)
