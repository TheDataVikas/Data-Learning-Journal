-- ============================================================
-- Problem   : Odd and Even Measurements
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Window Functions, Case
-- URL       : https://datalemur.com/questions/odd-even-measurements
-- Solved    : 2026-07-09
-- ============================================================

-- PROBLEM STATEMENT:
-- Assume you're given a table with measurement values obtained from a Google sensor over multiple days with measurements taken multiple times within each day.
-- Write a query to calculate the sum of odd-numbered and even-numbered measurements separately for a particular day and display the results in two different columns. Refer to the Example Output below for the desired format.
-- Definition:
--    Within a day, measurements taken at 1st, 3rd, and 5th times are considered odd-numbered measurements, and measurements taken at 2nd, 4th, and 6th times are considered even-numbered measurements.

-- APPROACH:
-- Create ranked measurement table first
-- write a case statement within final selection for even odd seggragation

-- SOLUTION:

WITH ranked_measurements AS(
  SELECT CAST(measurement_time AS date) AS measurement_day,
          measurement_value,
          row_number() OVER(
                            PARTITION BY CAST(measurement_time AS date)
                            ORDER BY measurement_time asc) AS rn
  FROM measurements
)
SELECT measurement_day,
      sum(CASE WHEN rn%2 = 1 THEN measurement_value ELSE 0 END) AS odd_sum,
      sum(CASE WHEN rn%2 = 0 THEN measurement_value ELSE 0 END) AS even_sum
FROM ranked_measurements
GROUP BY measurement_day;

-- WHAT I LEARNED / NOTES:
-- Gotcha: Remember the case statement is important here