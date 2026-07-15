# Databricks notebook / job source
# ============================================================
# SETUP: PySpark Syntax Drills — dummy data generator
# Creates {CATALOG}.{SCHEMA}.employees and .departments
# Idempotent: re-running this will NOT duplicate data unless you force it.
# ============================================================

import random
from datetime import date, timedelta
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType, StructField, IntegerType, StringType,
    DoubleType, DateType, BooleanType
)

# ------------------------------------------------------------
# CONFIG — change these if you like
# ------------------------------------------------------------
CATALOG = "de_practice"
SCHEMA = "dbo"
NUM_EMPLOYEES = 100
SEED = 42  # fixed seed -> same "random" data every time you regenerate

random.seed(SEED)

# ------------------------------------------------------------
# 1. Catalog + schema setup, with a safe fallback
# ------------------------------------------------------------
try:
    spark.sql(f"CREATE CATALOG IF NOT EXISTS {CATALOG}")
    spark.sql(f"USE CATALOG {CATALOG}")
except Exception as e:
    print(f"Could not create/use catalog '{CATALOG}' ({e}).")
    print("Falling back to the workspace's default catalog.")
    CATALOG = spark.sql("SELECT current_catalog()").collect()[0][0]
    print(f"Using catalog: {CATALOG}")

spark.sql(f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.{SCHEMA}")

print("=" * 60)
print(f"  Target: {CATALOG}.{SCHEMA}")
print("=" * 60)

# ------------------------------------------------------------
# 2. Idempotency check — skip regeneration if data already looks right
# ------------------------------------------------------------
_SETUP_SKIP = False
try:
    _emp_ct = spark.table(f"{CATALOG}.{SCHEMA}.employees").count()
    _dept_ct = spark.table(f"{CATALOG}.{SCHEMA}.departments").count()
    if _emp_ct >= NUM_EMPLOYEES and _dept_ct >= 5:
        _SETUP_SKIP = True
        print(f"  Tables already exist with expected row counts.")
        print(f"  employees={_emp_ct}, departments={_dept_ct}")
        print("  Skipping regeneration. Set FORCE_REBUILD=True below to override.")
except Exception:
    _SETUP_SKIP = False

FORCE_REBUILD = False  # flip to True if you want to wipe and regenerate on purpose
if FORCE_REBUILD:
    _SETUP_SKIP = False

# ------------------------------------------------------------
# 3. Generate dummy data (only runs if not skipped)
# ------------------------------------------------------------
if not _SETUP_SKIP:

    # ---- departments ----
    departments_data = [
        ("Engineering", "Bengaluru"),
        ("Sales",       "Mumbai"),
        ("HR",          "Delhi"),
        ("Marketing",   "Pune"),
        ("Finance",     "Hyderabad"),
        ("Operations",  "Chennai"),
    ]
    dept_schema = StructType([
        StructField("dept_name", StringType(), False),
        StructField("location",  StringType(), False),
    ])
    dept_df = spark.createDataFrame(departments_data, schema=dept_schema)

    dept_names = [d[0] for d in departments_data]

    # ---- employees ----
    # Deliberately includes "dirty" data so the syntax drills have something
    # real to work against: whitespace-padded names, nulls, name patterns.

    first_names = [
        "Aaron", "Alice", "Amit", "Anjali", "Andrew", "Ava", "Arjun",
        "Brian", "Chloe", "David", "Emma", "Farhan", "Grace", "Hannah",
        "Ishaan", "Julia", "Kevin", "Laura", "Manish", "Nina", "Oscar",
        "Priya", "Quinn", "Rohan", "Sara", "Tom", "Uma", "Vikram",
        "Wendy", "Yusuf"
    ]
    last_names = [
        "Johnson", "Anderson", "Robertson", "Wilson", "Jackson", "Thompson",
        "Patel", "Kumar", "Smith", "Brown", "Davis", "Garcia", "Martinez",
        "Sharma", "Gupta", "Nair", "Reddy", "Iyer", "Chen", "Lee",
        "Khan", "Singh", "Verma", "Rao", "Mehta", "Joshi", "Desai",
        "Bose", "Kapoor", "Malhotra"
    ]

    def random_date(start_year=2015, end_year=2024):
        start = date(start_year, 1, 1)
        end = date(end_year, 12, 31)
        delta_days = (end - start).days
        return start + timedelta(days=random.randint(0, delta_days))

    rows = []
    manager_pool = list(range(1, 11))  # emp_ids 1-10 are the "managers" (top-level, null manager_id)

    for emp_id in range(1, NUM_EMPLOYEES + 1):
        fname = random.choice(first_names)
        lname = random.choice(last_names)

        # inject whitespace dirt on ~10% of first names (for T14 trim() drill)
        if emp_id % 10 == 0:
            fname = f"  {fname}  "

        department = random.choice(dept_names)
        salary = round(random.uniform(45000, 150000), 2)
        hire_date = random_date()

        # top 10 emp_ids are managers with no manager (null); everyone else reports to one of them
        manager_id = None if emp_id <= 10 else random.choice(manager_pool)

        is_active = random.random() > 0.10  # ~90% active

        # ~40% have no bonus at all (null), for null-handling drills
        bonus = None if random.random() < 0.40 else round(random.uniform(500, 15000), 2)

        rows.append((
            emp_id, fname, lname, department, salary,
            hire_date, manager_id, is_active, bonus
        ))

    emp_schema = StructType([
        StructField("emp_id",      IntegerType(), False),
        StructField("first_name",  StringType(),  True),
        StructField("last_name",   StringType(),  True),
        StructField("department",  StringType(),  True),
        StructField("salary",      DoubleType(),  True),
        StructField("hire_date",   DateType(),    True),
        StructField("manager_id",  IntegerType(), True),
        StructField("is_active",   BooleanType(), True),
        StructField("bonus",       DoubleType(),  True),
    ])
    emp_df = spark.createDataFrame(rows, schema=emp_schema)

    # ---- write both tables as managed Delta tables ----
    dept_df.write.format("delta").mode("overwrite") \
        .saveAsTable(f"{CATALOG}.{SCHEMA}.departments")

    emp_df.write.format("delta").mode("overwrite") \
        .saveAsTable(f"{CATALOG}.{SCHEMA}.employees")

    print(f"  Created {CATALOG}.{SCHEMA}.departments ({dept_df.count()} rows)")
    print(f"  Created {CATALOG}.{SCHEMA}.employees ({emp_df.count()} rows)")

# ------------------------------------------------------------
# 4. Validation summary — quick sanity check the dirty data landed correctly
# ------------------------------------------------------------
df = spark.table(f"{CATALOG}.{SCHEMA}.employees")
dept_df = spark.table(f"{CATALOG}.{SCHEMA}.departments")

print("\n--- employees schema ---")
df.printSchema()

print("--- sample rows ---")
df.show(5, truncate=False)

print("--- departments ---")
dept_df.show(truncate=False)

print("--- data quality summary (confirms drill-ready dirty data) ---")
summary = df.select(
    F.count("*").alias("total_rows"),
    F.sum(F.when(F.col("manager_id").isNull(), 1).otherwise(0)).alias("null_manager_id"),
    F.sum(F.when(F.col("bonus").isNull(), 1).otherwise(0)).alias("null_bonus"),
    F.sum(F.when(F.col("first_name").rlike(r"^\s"), 1).otherwise(0)).alias("names_with_whitespace"),
    F.sum(F.when(F.col("first_name").startswith("A"), 1).otherwise(0)).alias("first_name_starts_with_A"),
    F.sum(F.when(F.col("last_name").contains("son"), 1).otherwise(0)).alias("last_name_contains_son"),
)
summary.show(truncate=False)

print(f"\nReady. Query with: spark.table('{CATALOG}.{SCHEMA}.employees')")
print(f"                    spark.table('{CATALOG}.{SCHEMA}.departments')")
