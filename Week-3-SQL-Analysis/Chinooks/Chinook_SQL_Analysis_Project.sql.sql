-- Display all tables available in the Chinook database
SELECT 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public';

-- View the columns and data types of the customer table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'customer';

-- View the columns and data types of the invoice table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'invoice';

-- View the columns and data types of the invoice_line table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'invoice_line';

-- View the columns and data types of the track table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'track';

-- View the columns and data types of the album table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'album';

-- View the columns and data types of the artist table
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'artist';

--Core SQL Queries
-- Display the first 10 customer records
SELECT *
FROM Customer
LIMIT 10;

-- Display customer names and their countries
SELECT 
	first_name,
	last_name,
	country
FROM Customer;

-- Retrieve customers who are located in the USA
SELECT 
	first_name,
	last_name,
	country
FROM Customer
WHERE country = 'USA';

-- Sort customers alphabetically by last name
SELECT 
	first_name,
	last_name,
	country
FROM Customer
ORDER BY last_name;

-- Count the total number of customers
SELECT 	
	COUNT(*) AS total_customers
FROM Customer;

-- Count the number of customers in each country
SELECT
	country,
	COUNT(*) AS total_customers
FROM Customer
GROUP BY country
ORDER BY total_customers DESC;

-- Calculate total revenue
SELECT 
	SUM(total) AS total_revenue
FROM invoice;

-- Calculate the average invoice amount
SELECT
    ROUND(AVG(total), 2) AS average_invoice_amount
FROM invoice;

-- Show countries with more than 2 customers
SELECT 
	country,
	COUNT(*) AS total_customers
FROM customer
GROUP BY country
HAVING COUNT(*) > 2
ORDER BY total_customers DESC;


--Advanced SQL Concepts
-- Display customer names with their invoice totals
SELECT 	
	c.first_name,
	c.last_name,
	i.invoice_id,
	i.total
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id;

-- Display all customers and their invoices
SELECT 	
	c.first_name,
	c.last_name,
	i.invoice_id,
	i.total
FROM customer AS c
LEFT JOIN invoice AS i
ON c.customer_id = i.customer_id;

-- Show all invoices and the customer information when available
SELECT
    c.first_name,
    i.invoice_id,
    i.total
FROM customer AS c
RIGHT JOIN invoice AS i
ON c.customer_id = i.customer_id;

--Subqueries
-- Find invoices that are above the average invoice amount
SELECT 
	invoice_id,
	customer_id,
	total
FROM invoice
WHERE total >
(SELECT 
	AVG(total) 
FROM invoice);

-- Find the customer(s) with the highest total spending
SELECT 
	customer_id,
	SUM(total) AS total_spent
FROM invoice
GROUP BY customer_id
HAVING SUM(total) =
(
SELECT
	MAX(customer_total)
FROM
(
SELECT 
		customer_id,
		SUM(total) AS customer_total
	FROM invoice
	GROUP BY customer_id
	) AS spending
);

--Find customers who have made more invoices than the average customer
SELECT 
	customer_id,
	COUNT(invoice_id) AS invoice_count
FROM invoice
GROUP BY customer_id
HAVING COUNT(invoice_id) >
(
SELECT
	AVG(invoice_count)
FROM

(
SELECT 
	customer_id,
	COUNT(invoice_id) invoice_count
FROM invoice
GROUP BY customer_id) invoice_summary
);

--Find customers who have never made a purchase
SELECT 
	customer_id,
	first_name,
	last_name
FROM customer
WHERE customer_id NOT IN 
(
SELECT 
	customer_id
FROM invoice);

-- Assign a unique row number to each invoice
SELECT 
	customer_id,
	invoice_id,
	total,
	ROW_NUMBER() OVER (ORDER BY invoice_id) AS row_number
FROM invoice;

-- Rank invoices based on total amount (highest to lowest)
SELECT
    invoice_id,
    customer_id,
    total,
    RANK() OVER (ORDER BY total DESC) AS invoice_rank
FROM invoice;

---- Number each customer's invoices separately
SELECT
	customer_id,
	invoice_id,
	invoice_date,
	ROW_NUMBER() OVER(
		PARTITION BY customer_id
		ORDER BY invoice_date
	) AS invoice_number
FROM invoice;


--Business Problem Solving
--Top-performing products or customers
--Top 5 customers by revenue
SELECT 
	c.customer_id,
	c.first_name,
    c.last_name,
	SUM(i.total) AS revenue
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id,
		 c.first_name,
		  c.last_name
ORDER BY revenue DESC
LIMIT 5;

--Which 5 tracks generated the highest revenue?
SELECT 
    t.track_id,
    t.name AS track_name,
    COUNT(il.invoice_line_id) AS times_purchased,
    SUM(il.unit_price * il.quantity) AS revenue
FROM track AS t
INNER JOIN invoice_line AS il
ON t.track_id = il.track_id
GROUP BY 
    t.track_id,
    t.name
ORDER BY revenue DESC
LIMIT 5;

--How has revenue changed over time?
SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    EXTRACT(MONTH FROM invoice_date) AS month,
    SUM(total) AS revenue
FROM invoice
GROUP BY 
    year,
    month
ORDER BY 
    year,
    month;

--Customer purchasing behavior
--Number of purchases and total spending by customer
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(i.invoice_id) AS total_purchases,
    SUM(i.total) AS total_spent
FROM customer AS c
INNER JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_purchases DESC;

-- Query Optimization
-- Creating an index to improve JOIN performance

CREATE INDEX idx_invoice_customer_id
ON invoice(customer_id);

-- Creating an index on invoice_date because it is used
-- for time-based revenue analysis.

CREATE INDEX idx_invoice_date
ON invoice(invoice_date);
	