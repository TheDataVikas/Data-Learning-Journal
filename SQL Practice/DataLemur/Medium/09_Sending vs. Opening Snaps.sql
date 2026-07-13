-- ============================================================
-- Problem   : Sending vs. Opening Snaps
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, SubQuery
-- URL       : https://datalemur.com/questions/time-spent-snaps
-- Solved    : 2026-07-13
-- ============================================================

-- PROBLEM STATEMENT:
-- Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.
-- Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

-- Notes:

--     Calculate the following percentages:
--         time spent sending / (Time spent sending + Time spent opening)
--         Time spent opening / (Time spent sending + Time spent opening)
--     To avoid integer division in percentages, multiply by 100.0 and not 100.


-- APPROACH:
-- Create the required aggreagation table first then proceed for % calculation

-- SOLUTION:

WITH time_table AS(
  SELECT ab.age_bucket,
        sum(CASE WHEN activity_type = 'send' THEN time_spent ELSE 0 END) AS send_time,
        sum(CASE WHEN activity_type = 'open' THEN time_spent ELSE 0 END) AS open_time,
        sum(CASE WHEN activity_type IN ('open', 'send') THEN time_spent ELSE 0 END) AS total_time
  FROM activities a
  LEFT JOIN age_breakdown ab ON a.user_id = ab.user_id
  GROUP BY age_bucket
)
 SELECT  age_bucket,
          round(100 * send_time/total_time, 2) AS send_perc,
          round(100 * open_time/total_time, 2) AS open_perc
  FROM time_table;

-- ALTERNATIVE APPROACH (if any):

-- WHAT I LEARNED / NOTES:
