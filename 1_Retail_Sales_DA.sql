drop table if exists RETAIL_SALES;
create table retail_sales
			(
				transactions_id int primary key,
				sale_date date,
				sale_time time,
				customer_id int,
				gender varchar(15),
				age int,
				category varchar(15),
				quantiy int,
				price_per_unit float,
				cogs float,
				total_sale float		
			);

ALTER TABLE retail_sales
RENAME COLUMN quantiy TO quantity;

select
	*
from
	retail_sales
limit 10;

-- Exploratory Data Analysis 
select
	count(*)
from
	retail_sales;


select
	retail_sales.transactions_id
from
	retail_sales
where
	retail_sales.transactions_id is null;

-- Handling null values
select
	*
from
	retail_sales
where
	category is null
	or customer_id is null
	or cogs is null
	or gender is null
	or sale_time is null
	or sale_date is null
	or price_per_unit is null
	or total_sale is null
	
delete
from
	retail_sales
where
	category is null
	or customer_id is null
	or cogs is null
	or gender is null
	or sale_time is null
	or sale_date is null
	or price_per_unit is null
	or total_sale is null
	
select
	count(*)
from
	retail_sales
	
-- Count unique customers
select
	count(distinct customer_id)
from
	retail_sales; 

-- Count unique category 
select
	count(distinct category )
from
	retail_sales; 


-- 1. Thống kê mô tả tổng quan (Descriptive Statistics) cho các biến số
SELECT 
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 2) AS avg_age,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    ROUND(AVG(quantity), 2) AS avg_quantity,
    MIN(total_sale) AS min_sale,
    MAX(total_sale) AS max_sale,
    ROUND(AVG(total_sale)::numeric, 2) AS avg_sale
FROM retail_sales;

-- 2. Xác định biên thời gian của dữ liệu (Data Timeline)
SELECT 
    MIN(sale_date) AS start_date, 
    MAX(sale_date) AS end_date,
    (MAX(sale_date) - MIN(sale_date)) AS total_days_of_data
FROM retail_sales;

-- 3. Thống kê số lượng và tỷ lệ % giao dịch theo giới tính
SELECT 
    gender, 
    COUNT(*) AS transaction_count,
    ROUND((COUNT(*)::numeric / (SELECT COUNT(*) FROM retail_sales) * 100), 2) AS percentage
FROM retail_sales
GROUP BY gender;

-- 4. Thống kê hiệu quả tài chính sơ bộ (Initial Profitability)
-- Tính toán tổng lợi nhuận gộp và tỷ suất lợi nhuận gộp ban đầu
SELECT 
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cogs,
    (SUM(total_sale) - SUM(cogs)) AS total_gross_profit,
    ROUND(((SUM(total_sale) - SUM(cogs)) / SUM(total_sale) * 100)::numeric, 2) AS gross_profit_margin_pct
FROM retail_sales;

-- 5. Kiểm tra tính toàn vẹn logic của dữ liệu (Data Integrity Check)	
SELECT COUNT(*) AS anomalous_rows
FROM retail_sales
WHERE ABS(total_sale - (quantity * price_per_unit)) > 0.01;



-- Data Analysis | Business key problems | Answers

 -- My Analysis & Findings
/*
Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
*/

-- Q1: Write a SQL query to retrieve all columns for sales made on '2022-11-05' 
select
	*
from
	retail_sales
where
	sale_date = '2022-11-05'
	
-- Q2: Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more 3 in the month of Nov-2022
select
	*
from
	retail_sales
where
	category = 'Clothing'
	and 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	and
    quantity > 3

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select
	category ,
	sum(total_sale) as total_sale_each
from
	retail_sales
group by
	category
order by
	total_sale_each desc

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
	select
	customer_id ,
	AVG(total_sale) as avg_price
from
	retail_sales
where
	category = 'Beauty'
group by
	customer_id
order by
	avg_price desc
	
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select
	*
from
	retail_sales
where
	total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select
	gender ,
	category ,
	count(*)
from
	retail_sales
group by
	gender ,
	category 

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
select avg(total_sale ), to_char(sale_date , 'mm-yyyy') as month_of_year
from retail_sales 
group by month_of_year
order by avg DESC
	
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select
	customer_id ,
	sum(total_sale) as total_sale_each_cus
from
	retail_sales
group by
	customer_id
order by total_sale_each_cus
	desc
limit 5;
	
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category ,
	count(distinct customer_id)
from
	retail_sales
group by
	category
	
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
	
-- Note that some versions do not allow grouping with alias names due to SQL execution order.
select
	count(*) as num_of_order,
	case
		when extract(hour from sale_time) <= 11 then 'Morning'
		when extract(hour from sale_time) <= 17 then 'Afternoon'
		when extract(hour from sale_time) > 17 then 'Evening'
	end as frame_time
from
	retail_sales
group by
	frame_time

	
-- Using common table expression 
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift
