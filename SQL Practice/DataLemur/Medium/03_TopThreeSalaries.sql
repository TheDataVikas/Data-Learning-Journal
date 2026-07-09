-- ============================================================
-- Problem   : Top Three Salaries
-- Platform  : DataLemur
-- Difficulty: Medium
-- Topic(s)  : CTEs, Window Functions
-- URL       : https://datalemur.com/questions/sql-top-three-salaries
-- Solved    : 2026-07-09
-- ============================================================

-- PROBLEM STATEMENT:
-- As part of an ongoing analysis of salary distribution within the company, your manager has requested a report identifying high earners in each department. A 'high earner' within a department is defined as an employee with a salary ranking among the top three salaries within that department.
-- You're tasked with identifying these high earners across all departments. Write a query to display the employee's name along with their department name and salary. In case of duplicates, sort the results of department name in ascending order, then by salary in descending order. If multiple employees have the same salary, then order them alphabetically.
-- Note: Ensure to utilize the appropriate ranking window function to handle duplicate salaries effectively.

-- APPROACH:
-- Create ranked empployeetable first
-- join it with the department and then select the final selection and order the results

-- SOLUTION:

WITH rnk_employee as (
  SELECT *, dense_rank() OVER(PARTITION by department_id order by salary DESC) as rnk
  FROM employee
)
select department_name, name, salary
from rnk_employee rnke
left join department d on rnke.department_id = d.department_id
where rnk <= 3
ORDER BY department_name ASC,
          salary DESC,
          name ASC;

-- WHAT I LEARNED / NOTES:
-- Gotcha: Remember the ask is for top 3 distinct salaries and not for top three paid employee's.
-- i.e. it should use dense rank to get all the rows with tie.
