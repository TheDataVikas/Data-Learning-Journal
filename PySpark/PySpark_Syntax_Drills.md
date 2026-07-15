# PySpark Syntax Drills (32 tasks)

**Purpose:** pure syntax muscle-memory. Not logic puzzles, not interview questions, just "how do I type this correctly." Do these in your free time, Answer key is at the bottom, no need to Google.

---

## The dataset

**`employees`**

| Column | Type | Notes |
|---|---|---|
| emp_id | int | |
| first_name | string | some have leading/trailing spaces |
| last_name | string | |
| department | string | e.g. Engineering, Sales, HR |
| salary | double | |
| hire_date | string | format "2022-05-14" |
| manager_id | int | nullable, top-level managers have null |
| is_active | boolean | |
| bonus | double | nullable |

**`departments`**

| Column | Type |
|---|---|
| dept_name | string |
| location | string |

Setup boilerplate (run once):
```python
from pyspark.sql import functions as F
from pyspark.sql.types import *

# assume df and dept_df already exist as DataFrames matching the schemas above
```

---

## THE TASKS

### Select & basic structure
1. Select just `first_name` and `last_name` from `df`.
2. Select all columns **except** `manager_id`.
3. Select `salary`, but rename it to `annual_salary` in the output (use `.alias()`).
4. Print the schema of `df` and show 5 rows without truncating long strings.

### Filtering
5. Filter rows where `department` equals `"Engineering"`.
6. Filter rows where `salary` is greater than `50000` **and** `is_active` is `True`.
7. Filter rows where `department` is `"Sales"` **or** `"HR"` (two ways: `|` operator and `.isin()`).
8. Filter rows where `manager_id` **is null**.
9. Filter rows where `bonus` **is not null**.
10. Filter rows where `first_name` starts with `"A"`.
11. Filter rows where `last_name` contains the substring `"son"`.

### Adding / modifying columns
12. Add a new column `full_name` that concatenates `first_name` and `last_name` with a space between them.
13. Add a new column `salary_in_k` equal to `salary / 1000`.
14. Overwrite `first_name` by trimming leading/trailing whitespace.
15. Add a new column `department_upper` with `department` fully uppercased.
16. Cast `salary` from double to integer, storing it in a new column `salary_int`.

### Conditional logic
17. Add a column `seniority` that says `"Senior"` if `salary > 90000`, `"Mid"` if `salary` is between `50000` and `90000`, else `"Junior"` (use `when` / `otherwise`).
18. Add a column `bonus_flag` that says `"Has Bonus"` if `bonus` is not null, else `"No Bonus"`.

### Null handling
19. Replace all null values in `bonus` with `0`.
20. Drop any row where `manager_id` is null.

### Renaming & dropping
21. Rename `emp_id` to `employee_id` using `.withColumnRenamed()`.
22. Drop the `manager_id` column entirely from the DataFrame.

### Sorting
23. Sort the DataFrame by `salary` descending.
24. Sort by `department` ascending, then by `salary` descending within each department (multi-column sort).

### Grouping & aggregation
25. Group by `department` and count how many employees are in each.
26. Group by `department` and compute the average salary per department, naming the output column `avg_salary`.
27. Group by `department` and compute min, max, and average salary all in one `.agg()` call.

### Distinct & dedup
28. Get the distinct list of `department` values.
29. Drop duplicate rows based on `department` only (keep one row per department, any row).

### Joins
30. Join `df` with `dept_df` where `df.department == dept_df.dept_name`, keeping all columns from both.
31. Same join as above, but select only `first_name`, `department`, and `location` in the result.

### Bonus: SQL-style shortcut
32. Use `selectExpr()` to select `first_name`, and a computed column `salary * 1.1 AS raised_salary` in one line, SQL-expression style.

---

## ANSWER KEY (full syntax reference)

```python
# 1. Select two columns
df.select("first_name", "last_name")

# 2. Select all except one
df.drop("manager_id")

# 3. Select with alias
df.select(F.col("salary").alias("annual_salary"))

# 4. Schema + show
df.printSchema()
df.show(5, truncate=False)

# 5. Filter equals
df.filter(F.col("department") == "Engineering")
# equivalent: df.filter("department = 'Engineering'")

# 6. Filter AND
df.filter((F.col("salary") > 50000) & (F.col("is_active") == True))

# 7. Filter OR (two ways)
df.filter((F.col("department") == "Sales") | (F.col("department") == "HR"))
df.filter(F.col("department").isin("Sales", "HR"))

# 8. Filter is null
df.filter(F.col("manager_id").isNull())

# 9. Filter is not null
df.filter(F.col("bonus").isNotNull())

# 10. Filter startsWith
df.filter(F.col("first_name").startswith("A"))

# 11. Filter contains
df.filter(F.col("last_name").contains("son"))

# 12. Concat columns
df.withColumn("full_name", F.concat(F.col("first_name"), F.lit(" "), F.col("last_name")))
# alternative: F.concat_ws(" ", "first_name", "last_name")

# 13. Arithmetic on column
df.withColumn("salary_in_k", F.col("salary") / 1000)

# 14. Trim whitespace, overwrite
df.withColumn("first_name", F.trim(F.col("first_name")))

# 15. Uppercase
df.withColumn("department_upper", F.upper(F.col("department")))

# 16. Cast type
df.withColumn("salary_int", F.col("salary").cast("int"))
# alternative: .cast(IntegerType())

# 17. Multi-condition when/otherwise
df.withColumn(
    "seniority",
    F.when(F.col("salary") > 90000, "Senior")
     .when(F.col("salary") >= 50000, "Mid")
     .otherwise("Junior")
)

# 18. Simple when/otherwise
df.withColumn(
    "bonus_flag",
    F.when(F.col("bonus").isNotNull(), "Has Bonus").otherwise("No Bonus")
)

# 19. Fill nulls
df.na.fill({"bonus": 0})
# alternative: df.fillna(0, subset=["bonus"])

# 20. Drop rows with nulls
df.na.drop(subset=["manager_id"])
# alternative: df.dropna(subset=["manager_id"])

# 21. Rename column
df.withColumnRenamed("emp_id", "employee_id")

# 22. Drop column
df.drop("manager_id")

# 23. Sort descending
df.orderBy(F.col("salary").desc())
# alternative: df.sort(F.desc("salary"))

# 24. Multi-column sort
df.orderBy(F.col("department").asc(), F.col("salary").desc())

# 25. Group + count
df.groupBy("department").count()

# 26. Group + avg with alias
df.groupBy("department").agg(F.avg("salary").alias("avg_salary"))

# 27. Group + multiple aggs
df.groupBy("department").agg(
    F.min("salary").alias("min_salary"),
    F.max("salary").alias("max_salary"),
    F.avg("salary").alias("avg_salary")
)

# 28. Distinct values
df.select("department").distinct()

# 29. Drop duplicates on subset
df.dropDuplicates(["department"])

# 30. Join, all columns
df.join(dept_df, df.department == dept_df.dept_name, "inner")

# 31. Join, select specific columns
df.join(dept_df, df.department == dept_df.dept_name, "inner") \
  .select("first_name", "department", "location")

# 32. selectExpr SQL-style
df.selectExpr("first_name", "salary * 1.1 AS raised_salary")
```

---

## How to use this

- **First pass:** try to write each task from memory, no peeking. Time yourself loosely.
- **Second pass (a day or two later):** redo the ones that took you more than ~60 seconds the first time.
- **Notice the patterns, not just the syntax.** Most of these tasks reduce to one of four shapes:
  - `df.select(...)` → pick columns
  - `df.filter(...)` / `df.where(...)` → pick rows
  - `df.withColumn("name", expr)` → add/replace a column
  - `df.groupBy(...).agg(...)` → collapse rows

  Once your fingers know these four shapes cold, almost every "simple" PySpark line is just a variation on one of them.

- **The most common beginner snag** : **Column-object style** (`df.filter(F.col("salary") > 50000)`). This drill sheet uses Column-object style throughout (the `F.col(...)` pattern) because it's what you'll need for anything conditional (`when`/`otherwise`) or type-safe, so building that habit now pays off later.
