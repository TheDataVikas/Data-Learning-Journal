-- ============================================================
-- Problem   : Second Highest Salary
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Window Functions
-- URL       : https://datalemur.com/questions/sql-second-highest-salary
-- Solved    : 2026-07-09
-- ============================================================

-- PROBLEM STATEMENT:
-- Imagine you're an HR analyst at a tech company tasked with analyzing employee salaries. Your manager is keen on understanding the pay distribution and asks you to determine the second highest salary among all employees.
-- It's possible that multiple employees may share the same second highest salary. In case of duplicate, display the salary only once.

-- APPROACH:
-- Create ranked employee table first
-- filter the final selection on the row number

-- SOLUTION:

WITH rn_employee as(
SELECT salary,
      row_number() over(ORDER BY salary DESC) as rn
FROM employee
)
SELECT salary as second_highest_salary
FROM rn_employee
WHERE rn = 2;

-- WHAT I LEARNED / NOTES:
-- Gotcha: Remember the ask is for 2nd highest Salary and if ties then it should appear once.
-- row_number is perfect candidate here