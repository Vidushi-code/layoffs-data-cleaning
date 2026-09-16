-- DATA CLEANING

-- 1. REMOVE THE DUPLICATES 
-- 2. STANDERDIZE THE DATA 
-- 3. NULL VALUE OR BLACK VALUE 
-- 4. REMOVE UNNECESSARY COLUMNS 

SELECT * FROM layoffs_staging;

SELECT * ,
 ROW_NUMBER() OVER(
	PARTITION BY company , location , industry , total_laid_off , percentage_laid_off, `date`, stage , country , funds_raised_millions
)
AS Row_num
FROM layoffs_staging;


WITH duplicate_cte AS 
(SELECT * ,
 ROW_NUMBER() OVER(
	PARTITION BY company , location , industry , total_laid_off , percentage_laid_off, `date`, 
    stage , country , funds_raised_millions
	)
	AS Row_num
	FROM layoffs_staging
)
DELETE  
FROM duplicate_cte 
WHERE Row_num >1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO 
layoffs_staging2
SELECT * ,
 ROW_NUMBER() OVER(
	PARTITION BY company , location , industry , total_laid_off ,
    percentage_laid_off, `date`, stage , country , funds_raised_millions
)
AS Row_num
FROM layoffs_staging
;
-- Deleting the duplicate data 
DELETE  FROM layoffs_staging2 
WHERE Row_num > 1;


SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
ADD COLUMN New_row_num INT;

SELECT * ,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
    ORDER BY company
) AS New_row_num
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
ADD COLUMN temp_id INT AUTO_INCREMENT UNIQUE;

UPDATE layoffs_staging2 t
JOIN (
    SELECT 
        temp_id,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off,
            percentage_laid_off, `date`, stage, country, funds_raised_millions
            ORDER BY temp_id
        ) AS row_num
    FROM layoffs_staging2
) x
ON t.temp_id = x.temp_id
SET t.New_row_num = x.row_num;



DELETE FROM layoffs_staging2 
WHERE New_row_num >1;

ALTER TABLE layoffs_staging2
DROP COLUMN temp_id;

ALTER TABLE layoffs_staging2 
DROP COLUMN Row_num;

SELECT * FROM layoffs_staging2;

-- Standardizing data 

SELECT company , TRIM(company) 
-- deleting the extra place in the starting of the column 
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET industry ='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Converting the data type of the date column from text to date 
-- We always use %m/%d/%Y this format (lower case m , lowe case d , and an upper case y )
SELECT `date` 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y') ;

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;



-- Working with NULL and blank values 


SELECT t1.industry , t2.industry 
FROM layoffs_staging2 t1 
JOIN layoffs_staging2 t2 
	ON t1.company = t2.company 
	WHERE (t1.industry IS NULL OR t1.industry ='')
	AND t2.industry IS NOT NULL;
    
UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
	WHERE t1.industry IS NULL 
	AND t2.industry IS NOT NULL;
     

UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry ='';

SELECT * FROM 
layoffs_staging2 ;

-- we may not need the rows  in future that that total_laid_off and percentage_laid_off as NULL values , 
-- because we  gonna do the exploratory data analysis in future 
-- that is why we are deleting those rows 

DELETE FROM 
layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL ;

-- Removing the unnecessary columns 

ALTER TABLE layoffs_staging2 
DROP COLUMN New_row_num;

-- Final cleaned data 

SELECT * FROM 
 layoffs_staging2;
 
