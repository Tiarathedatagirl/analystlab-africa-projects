CREATE DATABASE AnalystLab_Netflix

USE AnalystLab_Netflix

--Display the first few rows
SELECT TOP 10 *
FROM netflix_titles;

--Number of Rows
SELECT COUNT(*) AS TotalRows
FROM netflix_titles;

--Number of Columns
SELECT COUNT(*) AS TotalColumns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'netflix_titles';

--Data types of all columns
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'netflix_titles';

-- Numerical Features:
--release_year

--Categorical Features
--show_id
--type
--title
--director
--cast
--country
--date_added
--rating
--duration
--listed_in
--description

--Possible unique identifiers (primary keys)
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT show_id) AS UniqueShowIDs
FROM netflix_titles;

--Task 2: Data Cleaning
-- Check for missing values
--Show the number of missing values per column.
SELECT
    SUM(CASE WHEN show_id IS NULL THEN 1 ELSE 0 END) AS show_id_missing,
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS type_missing,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_missing,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_missing,
    SUM(CASE WHEN cast IS NULL THEN 1 ELSE 0 END) AS cast_missing,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_missing,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_missing,
    SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS release_year_missing,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_missing,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_missing,
    SUM(CASE WHEN listed_in IS NULL THEN 1 ELSE 0 END) AS listed_in_missing,
    SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS description_missing
FROM netflix_titles;

---- Create a copy of the original dataset for cleaning
SELECT *
INTO netflix_titles_clean
FROM netflix_titles;

SELECT COUNT(*) AS TotalRows
FROM netflix_titles_clean;

-- Replace missing director values with 'Unknown'
UPDATE netflix_titles_clean
SET director = 'Unknown'
WHERE director IS NULL;

SELECT
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_missing
FROM netflix_titles_clean;

-- Replace missing cast values with 'Unknown'
UPDATE netflix_titles_clean
SET Cast = 'Unknown'
WHERE Cast IS NULL;

SELECT
    SUM(CASE WHEN cast IS NULL THEN 1 ELSE 0 END) AS cast_missing
FROM netflix_titles_clean;

-- Replace missing country values with 'Unknown'
UPDATE netflix_titles_clean
SET Country = 'Unknown'
WHERE Country IS NULL;

SELECT
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS  country_missing
FROM netflix_titles_clean;

-- Replace missing rating values with 'Not Rated'
UPDATE netflix_titles_clean
SET rating = 'Not Rated'
WHERE rating IS NULL;

SELECT
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS  rating_missing
FROM netflix_titles_clean;

-- Inspect records with missing duration
SELECT *
FROM netflix_titles
WHERE duration IS NULL;

SELECT
    show_id,
    title,
    rating,
    duration
FROM netflix_titles_clean
WHERE duration IS NULL;

-- Move duration values from rating to duration
UPDATE netflix_titles_clean
SET
    duration = rating,
    rating = 'Not Rated'
WHERE duration IS NULL
  AND rating LIKE '%min';

 SELECT
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_missing,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_missing
FROM netflix_titles_clean;

-- Verify Missing Values: date_added
SELECT
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_missing
FROM netflix_titles_clean;


-- Check for duplicate records based on all columns
SELECT
    show_id,
    COUNT(*) AS DuplicateCount
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

-- Verify duplicate records in the cleaned dataset
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT show_id) AS UniqueShowIDs,
    COUNT(*) - COUNT(DISTINCT show_id) AS DuplicateRows
FROM netflix_titles_clean;

--Standardization
-- Check date format
SELECT TOP 10
    date_added
FROM netflix_titles_clean;

-- Check text formatting
SELECT TOP 10
    type,
    country,
    rating
FROM netflix_titles_clean;

-- Column names
SELECT
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS

-- Data types
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'netflix_titles_clean';

-- Invalid values
SELECT DISTINCT type
FROM netflix_titles_clean;

-- Check for inconsistent records
SELECT
    show_id,
    type,
    title,
    duration
FROM netflix_titles_clean
WHERE
    (type = 'Movie' AND duration NOT LIKE '%min')
    OR
    (type = 'TV Show' AND duration NOT LIKE '%Season%');

-- Check for outliers or anomalies in release_year
SELECT
    show_id,
    title,
    release_year
FROM netflix_titles_clean
WHERE release_year > YEAR(GETDATE())
   OR release_year < 1900;


--Task 3: Exploratory Data Analysis (EDA)
---Mean
SELECT
    AVG(CAST(release_year AS FLOAT)) AS Mean_Release_Year
FROM netflix_titles_clean;

--Median
SELECT DISTINCT
    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY release_year)
    OVER () AS Median_Release_Year
FROM netflix_titles_clean;

--Minimum, Maximum, Standard Deviation
SELECT
    MIN(release_year) AS Minimum_Year,
    MAX(release_year) AS Maximum_Year,
    STDEV(release_year) AS Standard_Deviation
FROM netflix_titles_clean;


--Movies vs TV Shows distribution
SELECT
    type,
    COUNT(*) AS TotalTitles
FROM netflix_titles_clean
GROUP BY type
ORDER BY TotalTitles DESC;

--Content added by year
SELECT
    YEAR(date_added) AS AddedYear,
    COUNT(*) AS TotalTitles
FROM netflix_titles_clean
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY AddedYear DESC;

--Top content-producing countries
SELECT TOP 10 
		country,
		COUNT(*) AS TotalTitles
FROM netflix_titles_clean
WHERE country <> 'Unknown'
GROUP BY country
ORDER BY TotalTitles DESC;

SELECT * FROM netflix_titles_clean
--Most common ratings
SELECT 
	rating,
	COUNT(*) AS TotalTitles
FROM netflix_titles_clean
GROUP BY rating
ORDER BY TotalTitles DESC;

--Most common genres/categories
SELECT TOP 10
	listed_in,
	COUNT(*) AS TotalTitles
FROM netflix_titles_clean
GROUP BY listed_in
ORDER BY TotalTitles DESC;

