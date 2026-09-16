# Layoffs Data Cleaning & Analysis Using SQL

## Project Overview

This project uses a public tech layoffs dataset  and MySQL to perform end-to-end data cleaning and transformation. The raw dataset contained duplicate records, inconsistent text formatting, incorrect data types, and missing values — this project cleans and standardizes it so it is ready for exploratory/business analysis.

This  project is focused on applying core SQL cleaning techniques on a real-world, messy dataset.

## Objectives

- Identify and remove duplicate records
- Standardize inconsistent categorical values
- Handle NULL and blank values
- Convert the `date` column from text to a proper `DATE` type
- Remove unnecessary/helper columns created during the cleaning process
- Produce a cleaner dataset suitable for downstream analysis

## Dataset

The raw dataset (`layoffs.csv`) contains **2,361 records** with the following columns:

| Column | Description |
|---|---|
| `company` | Name of the company |
| `location` | City/location of the company |
| `industry` | Industry the company operates in |
| `total_laid_off` | Number of employees laid off |
| `percentage_laid_off` | Percentage of workforce laid off |
| `date` | Date the layoff was reported |
| `stage` | Company funding/growth stage (e.g. Post-IPO, Series B) |
| `country` | Country of the company |
| `funds_raised_millions` | Total funds raised by the company (in millions USD) |

**Source & License:** The dataset is publicly available on Kaggle under the Open Data Commons Open Database License (ODbL), originally aggregated by Layoffs.fyi. See `data/README.md` for the source link and attribution details.

## Tools Used

- MySQL
- MySQL Workbench
- SQL
- GitHub

## Data Cleaning Process

**1. Staging Table**
The raw data was imported into MySQL and loaded into a staging table (`layoffs_staging`) so the original raw table would remain untouched during cleaning.

**2. Duplicate Identification & Removal**
`ROW_NUMBER()` with `PARTITION BY` was used across all nine columns (`company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`) to flag exact duplicate rows. A second staging table (`layoffs_staging2`) was created to carry out the removal — since window function results aren't directly deletable, a temporary auto-incrementing identifier (`temp_id`) was added to reliably assign row numbers, duplicates (`row_num > 1`) were deleted, and the helper columns were dropped afterward.

**3. Standardization**
- `TRIM()` was used to remove leading/trailing whitespace from `company` names.
- Industry values starting with "Crypto" (e.g. "Crypto Currency", "CryptoCurrency") were standardized to a single `"Crypto"` value.
- Country values starting with "United States" (e.g. a trailing-period variant) were standardized to `"United States"`.

**4. Date Conversion**
The `date` column was originally stored as text. `STR_TO_DATE()` was used to convert it (format `%m/%d/%Y`), and the column was then modified to a proper `DATE` data type using `ALTER TABLE`.

**5. NULL and Blank Value Handling**
- A self-join on `company` was used to find rows where `industry` was missing but another record for the same company had a non-null value, and those values were filled in.
- Remaining blank (`''`) industry values were converted to `NULL` for consistency.
- Rows where **both** `total_laid_off` and `percentage_laid_off` were `NULL` were removed, since these rows carried no usable information for the intended exploratory analysis.

**6. Removing Helper Columns**
Columns created only to support the cleaning process (`row_num`, `new_row_num`, `temp_id`) were dropped from the final table.

## SQL Techniques Used

- `SELECT`
- `CREATE TABLE`
- `INSERT INTO ... SELECT`
- `UPDATE`
- `DELETE`
- `ALTER TABLE` (add/drop/modify columns)
- `JOIN` (self-join)
- Common Table Expressions (`WITH ... AS`)
- Window functions — `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)`
- `TRIM()`
- `LIKE`
- `STR_TO_DATE()`
- `IS NULL`
- `AUTO_INCREMENT`

## Project Workflow

```
Raw Dataset
    ↓
MySQL Import
    ↓
Staging Table
    ↓
Duplicate Identification
    ↓
Duplicate Removal
    ↓
Standardization
    ↓
NULL / Blank Handling
    ↓
Data Type Conversion
    ↓
Final Clean Dataset
    ↓
Ready for Analysis
```

## Data Quality Improvements

These figures were calculated directly from `layoffs.csv` and the cleaning logic in the SQL script:

| Metric | Count |
|---|---|
| Original records (raw dataset) | 2,361 |
| Exact duplicate records identified & removed | 5 |
| Records remaining after duplicate removal | 2,356 |
| Missing (`NULL`) `industry` values found | 4 |
| `industry` values successfully filled via same-company match | 3 |
| `industry` values still `NULL` after fill (no matching company record) | 1 |
| Rows removed — both `total_laid_off` and `percentage_laid_off` were `NULL` | 361 |
| **Final cleaned record count** | **1,995** |

> Note: These numbers were independently recalculated from the raw CSV to verify the cleaning logic in the SQL script — they are not pulled from a query result, so treat them as a close approximation of what running the script in MySQL will produce.

## Key Learnings

- Creating and using staging tables to protect raw data while cleaning
- Identifying duplicate records using window functions (`ROW_NUMBER()` with `PARTITION BY`)
- Handling the fact that rows produced by a window function aren't always directly deletable, and working around it with a helper identifier column
- Filling missing values using a self-join on a related column (`company`)
- Standardizing inconsistent categorical text values with `LIKE` and `UPDATE`
- Converting a text column to a proper `DATE` type with `STR_TO_DATE()`
- Cleaning up helper/temporary columns to arrive at a final, analysis-ready table

## Project Structure

```
layoffs-data-cleaning/
├── README.MD
├── data/
│   └── layoffs.csv
├── screenshots/
│   ├── 01_raw_data.png
│   ├── 02_duplicate_detection.png
│   ├── 03_final_row_count.png
│   ├── 04_null_industry_selfjoin.png
│   └── 05_standardized_industry.png
└── sql/
    └── data_cleaning.sql
```

## How to Run

1. Import the raw dataset (`data/layoffs.csv`) into MySQL as a table named `layoffs_staging` (e.g. via MySQL Workbench's Table Data Import Wizard, or `LOAD DATA INFILE`).
2. Open `sql/data_cleaning_project.sql` in MySQL Workbench.
3. Run the script section by section, in order — it creates `layoffs_staging2`, removes duplicates, standardizes values, converts the `date` column, and handles NULL/blank values.
4. Once complete, query `layoffs_staging2` to view the final cleaned dataset.

## Future Improvements

- Add a separate SQL file for exploratory data analysis (EDA) on the cleaned dataset
- Answer specific business questions using SQL (e.g. layoffs by industry, by country, by year)
- Build a Power BI dashboard/visualization on top of the cleaned data
- Add data validation checks/tests to the cleaning script

## Author

**Vidushi Agarwal**
