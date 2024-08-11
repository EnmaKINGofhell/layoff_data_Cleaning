

-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


SELECT * FROM world_layoffs.layoffs_satages;
-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

 -- 1. deleting the duplicate rows
 
 
 
with double_data as  #using row number to every line to find the duplicate row 
(
	SELECT * ,
    ROW_NUMBER () OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions # using for all the row to get the duplicate number
    )AS ROW_NUM
    FROM layoffs_satages
)
SELECT *
FROM double_data 
WHERE row_num > 1; # where the number is more than 1 its is a duplicate row

CREATE TABLE `layoffs_satages2` (   # creating another stage table to delete the duplicate data to avoid erro in the real table 
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select * 
from layoffs_satages2; #inserting the data to the temp table to delete the duplicate data 

insert into layoffs_satages2
SELECT * ,
    ROW_NUMBER () OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
    )AS ROW_NUM
    FROM layoffs_satages
;


delete from layoffs_satages2  # deleting the duplicate data 
WHERE row_num > 1;

select * from layoffs_satages2 # checking if there is anay orther duplicate data 
WHERE row_num > 1;



 -- Standardizing data 
 
 
 select company , trim(company)   # deleting the white space 
 from layoffs_satages2 ;
 
 update layoffs_satages2     #  updating the value to the table 
 set company = trim(company);
 
 
 select *     # updating the similar names in the industry section 
 from layoffs_satages2;
 
 update layoffs_satages2 
 set  industry = 'crypto'
 where  industry like 'crypto%';
 
 
select distinct country , trim(trailing '.' from country)
from layoffs_satages2 ;

select country 
from layoffs_satages2 
where country like 'United States%' ;


update layoffs_satages2 
set country = trim(trailing '.' from country)
where country like 'United States%';

select date	                # here date is in a text fromat we need toe change it into a date and time fromat
from layoffs_satages2;

select `date`,
str_to_date (`date` , '%m/%d/%Y')			# the "STR_TO_DATE" fuction just changes the text to date format 
from layoffs_satages2;            			#'%m/%d/%Y' this the format for the date 

update layoffs_satages2
set `date` = str_to_date (`date` , '%m/%d/%Y') ; #updating the table but it doesn't change the data type of the column 
											
alter table layoffs_satages2
modify column `date` date;      # changed the data type to date using the alter and modify fuctions


-- 3. Look at Null Values

-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values




-- 4. remove any columns and rows we need to
	

update layoffs_satages2
set industry =null
where industry = '';


select *
from layoffs_satages2
where total_laid_off is null 
and percentage_laid_off is null;

DELETE FROM world_layoffs.layoffs_satages2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



select * 
from layoffs_satages2
where industry is null or industry ='';


select  t1.industry ,t2.industry
from layoffs_satages2 t1
join layoffs_satages2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null 
and t2.industry is not null;

update layoffs_satages2 t1
join layoffs_satages2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

select * from layoffs_satages2;




















