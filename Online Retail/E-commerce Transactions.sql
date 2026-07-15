--Display the first few rows
SELECT TOP 10 *
FROM OnlineRetail

--Number of Rows
SELECT COUNT(*) AS TotalRows
FROM OnlineRetail

--Number of Columns
SELECT COUNT(*) AS TotalColumns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OnlineRetail'

--Data types of all columns
SELECT 
	COLUMN_NAME,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OnlineRetail'

-- Numerical Features:
-- Quantity
-- UnitPrice

-- Categorical Features:
-- InvoiceNo
-- StockCode
-- Description
-- Country
--CustomerID

-- Date Feature:
-- InvoiceDate

-- Possible Unique Identifier:
-- No single column uniquely identifies each record.
-- A combination of InvoiceNo and StockCode is a possible composite key.

--Task 2: Data Cleaning
--• Identify columns with missing values & the number of missing values per column.
SELECT
	SUM(CASE WHEN InvoiceNo IS NULL THEN 1 ELSE 0 END)Invoice_Missing,
	SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END)StockCode_Missing,
	SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END)Description_Missing,
	SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END)Quantity_Missing,
	SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END)InvoiceDate_Missing,
	SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END)UnitPrice_Missing,
	SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END)Customer_Missing,
	SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)Country_Missing
FROM OnlineRetail

--Handle missing values: Description.
UPDATE OnlineRetail
SET Description = 'Unknown'
WHERE Description IS NULL

--Handle missing values: UnitPrice
DELETE FROM OnlineRetail
WHERE UnitPrice IS NULL

--Handle missing values:CustomerID
UPDATE OnlineRetail
SET CustomerID = NULL
WHERE CustomerID = 0

---Duplicate Records
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    COUNT(*) AS DuplicateCount
FROM dbo.OnlineRetail
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country
HAVING COUNT(*) > 1

--Remove duplicates where necessary.
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country
        ORDER BY InvoiceNo
    ) AS RowNum
INTO OnlineRetail_Clean
FROM OnlineRetail

--Remove duplicates where necessary.
DELETE FROM OnlineRetail_Clean
WHERE RowNum > 1

SELECT COUNT(*) AS TotalRows
FROM OnlineRetail_Clean

--Standardization
--Date formats
SELECT TOP 10 InvoiceDate
FROM OnlineRetail_Clean

--Text formatting (upper/lower case)
SELECT DISTINCT TOP 20 Description
FROM OnlineRetail_Clean
ORDER BY Description

UPDATE OnlineRetail_Clean
SET Description = UPPER(Description)
WHERE Description IS NOT NULL

SELECT DISTINCT Country
FROM OnlineRetail_Clean
ORDER BY Country

--Column names
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='OnlineRetail_Clean'

ALTER TABLE OnlineRetail_Clean
DROP COLUMN RowNum

--Data types
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OnlineRetail_Clean'

--Data Validation
--Invalid values

SELECT COUNT(*) AS NegativeQuantity
FROM OnlineRetail_Clean
WHERE Quantity < 0

-- Check for zero or negative unit prices
SELECT COUNT(*) AS ZeroOrNegativePrice
FROM OnlineRetail_Clean
WHERE UnitPrice <= 0;

-- Inspect records with zero or negative unit prices
SELECT TOP 20 InvoiceNo, StockCode, Description, Quantity, UnitPrice, CustomerID, Country
FROM OnlineRetail_Clean
WHERE UnitPrice <= 0
ORDER BY Quantity

-- Remove invalid zero/negative price records (not valid sales transactions)
DELETE FROM OnlineRetail_Clean
WHERE UnitPrice <= 0

-- Identify inconsistent country names
SELECT DISTINCT COUNTRY
FROM OnlineRetail_Clean
ORDER BY COUNTRY

UPDATE OnlineRetail_Clean
SET Country = 'Ireland'
WHERE Country = 'EIRE'

UPDATE OnlineRetail_Clean
SET Country = 'South Africa'
WHERE Country = 'RSA'

UPDATE OnlineRetail_Clean
SET Country = 'United States'
WHERE Country = 'USA'

--Outliers or anomalies where applicable
-- Check the range of quantity values
SELECT MAX(Quantity) AS MaxQuantity,
       MIN(Quantity) AS MinQuantity
FROM OnlineRetail_Clean

-- Inspect records with the highest quantities
SELECT TOP 10
    Quantity,
    Description,
    UnitPrice
FROM OnlineRetail_Clean
ORDER BY Quantity DESC


----Task 3: Exploratory Data Analysis (EDA)
SELECT 
    AVG(Quantity) AS MeanQuantity,
    MIN(Quantity) AS MinQuantity,
    MAX(Quantity) AS MaxQuantity,
    STDEV(Quantity) AS StdDevQuantity,
    AVG(UnitPrice) AS MeanUnitPrice,
    MIN(UnitPrice) AS MinUnitPrice,
    MAX(UnitPrice) AS MaxUnitPrice,
    STDEV(UnitPrice) AS StdDevUnitPrice
FROM OnlineRetail_Clean

SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Quantity)
        OVER () AS MedianQuantity,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY UnitPrice)
        OVER () AS MedianUnitPrice
FROM OnlineRetail_Clean

--Exploratory Analysis
--Top-selling products
SELECT TOP 10 *
FROM OnlineRetail_Clean

SELECT TOP 10 Description, SUM(Quantity) AS TotalQuantitySold
FROM OnlineRetail_Clean
WHERE Quantity > 0
GROUP BY Description
ORDER BY TotalQuantitySold DESC

--Highest revenue-generating countries
SELECT Country, 
	SUM(Quantity * UnitPrice) AS TotalReveune
FROM OnlineRetail_Clean
WHERE Quantity > 0
GROUP BY Country
ORDER BY TotalReveune DESC

--Monthly sales trends
SELECT
	YEAR(InvoiceDate) AS SalesYear,
	Month(InvoiceDate) AS SalesMonth,
	SUM(Quantity * UnitPrice) AS TotalReveune
FROM OnlineRetail_Clean
WHERE Quantity > 0
GROUP BY YEAR(InvoiceDate),
		 Month(InvoiceDate) 
ORDER BY  SalesYear,
	      SalesMonth

--Most purchased products
SELECT TOP 10 Description,
	COUNT(*) AS NumberOfPurchases
FROM OnlineRetail_Clean
WHERE Quantity > 0
GROUP BY Description
ORDER BY NumberOfPurchases DESC

--Customer purchasing behavior
SELECT 
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    SUM(Quantity * UnitPrice) AS TotalSpent
FROM OnlineRetail_Clean
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
GROUP BY CustomerID
ORDER BY TotalSpent DESC

