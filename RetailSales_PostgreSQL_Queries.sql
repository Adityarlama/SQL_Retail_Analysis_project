-- Creating the table

CREATE TABLE Retail_Sales (
		transaction_id	INT PRIMARY KEY,
		sale_date	DATE,
		sale_time	TIME,
		customer_id	INT,
		gender	varchar(25),
		age	 INT,
		category VARCHAR(30),
		quantity INT,
		price_per_unit FLOAT,
		cogs   float,
		total_sale float
		);

-- Limit query
SELECT * FROM Retail_Sales
ORDER BY sale_date ASC LIMIT 13;



-- Ascending 1 to 100 query
SELECT * FROM public.retail_sales
ORDER BY transaction_id ASC LIMIT 100


--- FINDING NULL VALUES
SELECT * FROM retail_sales 
WHERE
	transaction_id IS NULL OR 
	sale_date IS NULL OR 
	sale_time IS NULL OR 
	customer_id IS NULL OR 
	gender IS NULL OR 
	category IS NULL OR 
	quantity IS NULL OR 
	price_per_unit IS NULL OR 
	cogs IS NULL OR 
	total_sale IS NULL;

-- DELETE QUERY

DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL OR 
	sale_date IS NULL OR 
	sale_time IS NULL OR 
	customer_id IS NULL OR 
	gender IS NULL OR 
	category IS NULL OR 
	quantity IS NULL OR 
	price_per_unit IS NULL OR 
	cogs IS NULL OR 
	total_sale IS NULL;

--- Checking COUNT
SELECT COUNT(*) FROM retail_sales;
----------------------
----------------------
---DATA EXPLORATION---
----------------------

-- No of sales (everything basically)
SELECT COUNT (*) as total_sale FROM retail_sales

-- No of unique customers
SELECT COUNT (DISTINCT customer_ID) as unique_customers FROM retail_sales;

-- What are the categories in the 'category' table
SELECT DISTINCT category FROM retail_sales;



----------------------
----------------------
--BUSINESS ANALYTICS--
----------------------

-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT * FROM retail_sales WHERE category = 'Clothing' AND quantity >= 4 AND TO_CHAR (sale_date, 'YYYY-MM') = '2022-11' ORDER BY 1 ASC ;

SELECT * FROM retail_sales WHERE category = 'Clothing' AND TO_CHAR (sale_date, 'YYYY-MM') = '2022-11' ORDER BY 1 DESC;


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT COUNT (*) FROM retail_sales WHERE category = 'Beauty';
SELECT COUNT (*) FROM retail_sales WHERE category = 'Clothing';
SELECT COUNT (*) FROM retail_sales WHERE category = 'Electronics';
------- turns out there's a better way to do this 😂

SELECT
	category,
	SUM(total_sale) as net_sale,
	COUNT (*) as total_orders
FROM retail_sales
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
	AVG(age)as avg_customer_age
FROM retail_sales
WHERE category = 'Beauty'

----Here's how to not get full float values
SELECT
	ROUND(AVG(age),2) as avg_customer_age
FROM retail_sales
WHERE category = 'Beauty'



-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales WHERE total_sale < 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT gender, category, COUNT (*) as total_transactions FROM retail_sales
GROUP BY category, gender
ORDER BY 2, 1

-- so turns out it matters if you put 1,2 v/s 2,1 after ORDER BY

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT sale_date as YnM, SUM (total_sale) as total_sales_month
FROM retail_sales
GROUP BY sale_date
ORDER BY 2 DESC
	



---part 1 above

SELECT year, month, avg_sale
FROM (
SELECT
	EXTRACT (YEAR FROM sale_date) as year,
	EXTRACT (MONTH FROM sale_date) as month,
	AVG (total_sale) as avg_sale,
	RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS RANK
FROM retail_sales
GROUP BY 1,2
) 
WHERE rank = 1
ORDER BY 1,3 DESC



-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT
		customer_id, SUM(total_sale) as their_total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT
	category, COUNT(DISTINCT customer_id) as unique_customers
FROM retail_sales
GROUP BY category
ORDER BY COUNT(DISTINCT customer_id) DESC

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
	(
	SELECT *,
	    CASE
	        WHEN EXTRACT(HOUR from sale_time) < 12 THEN 'MORNING'
			WHEN EXTRACT(HOUR from sale_time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			ELSE 'EVENING'
	    END as Shift
	FROM retail_sales
	)
SELECT
	Shift, COUNT(*) as total_orders
FROM hourly_sale
GROUP by shift

/* SO INTERESTING
USING SELECT * and then a comma (huh?) to include the new CASE that's being made, and then calling that temporal column hourly_sale using WITH function


